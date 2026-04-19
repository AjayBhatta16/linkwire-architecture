terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
  
  backend "gcs" {
    bucket = "GCP_TERRAFORM_STATE_BUCKET"
    prefix = "terraform/state"
  }
}

provider "google" {
    project = var.project_id
    region = var.region
}

# placeholder code for cloud run functions

data "archive_file" "golang_function_stub" {
  type        = "zip"
  output_path = "${path.module}/.build/golang-stub.zip"

  source {
    content  = <<-EOT
        package function

        import (
            "fmt"
            "net/http"
        )

        func init() {
          funcframework.RegisterHTTPFunction("/", ProcessRequest)
        }

        func ProcessRequest(w http.ResponseWriter, r *http.Request) {
            fmt.Fprintln(w, "stub: not yet implemented")
        }
    EOT
    filename = "main.go"
  }
}


data "archive_file" "nodejs_function_stub" {
  type        = "zip"
  output_path = "${path.module}/.build/nodejs-stub.zip"

  source {
    content  = <<-EOT
        const functions = require('@google-cloud/functions-framework');
        functions.http('handler', (req, res) => {
            res.send('stub: not yet implemented');
        });
    EOT
    filename = "index.js"
  }

  source {
    filename = "package.json"
    content  = <<-EOT
      {
        "name": "stub",
        "version": "1.0.0",
        "main": "index.js",
        "dependencies": {
          "@google-cloud/functions-framework": "^3.0.0"
        }
      }
    EOT
  }
}

# storage bucket for cloud function source code

resource "google_storage_bucket" "function_source" {
  name     = var.function_src_bucket_name
  location = var.region
  uniform_bucket_level_access = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_object" "golang_stubs" {
  for_each = local.golang_functions

  name   = "${each.key}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.golang_function_stub.output_path

  lifecycle {
    ignore_changes = [source, detect_md5hash]
  }
}

resource "google_storage_bucket_object" "nodejs_stubs" {
  for_each = local.nodejs_functions

  name   = "${each.key}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.nodejs_function_stub.output_path

  lifecycle {
    ignore_changes = [source, detect_md5hash]
  }
}

# function infrastructure

resource "google_cloudfunctions2_function" "golang_functions" {
  for_each = local.golang_functions

  name        = each.key
  description = "Linkwire function: ${each.key}"
  location    = var.region

  build_config {
    runtime     = "go126"
    entry_point = "ProcessRequest"
    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.golang_stubs[each.key].name
      }
    }
  }

  service_config {
    min_instance_count = 0
    max_instance_count = 10
    available_memory = "256M"
    timeout_seconds = 60
    ingress_settings = "ALLOW_ALL"
    service_account_email = google_service_account.function_identity.email
  }

  lifecycle {
    ignore_changes = [build_config[0].source]
  }
}

resource "google_cloudfunctions2_function" "nodejs_functions" {
  for_each = local.nodejs_functions

  name        = each.key
  description = "Linkwire function: ${each.key}"
  location    = var.region

  build_config {
    runtime     = "nodejs24"
    entry_point = "handler"
    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.nodejs_stubs[each.key].name
      }
    }
  }

  service_config {
    min_instance_count = 0
    max_instance_count = 10
    available_memory = "256M"
    timeout_seconds = 60
    ingress_settings = "ALLOW_ALL"
    service_account_email = google_service_account.function_identity.email
  }

  lifecycle {
    ignore_changes = [build_config[0].source]
  }
}

# service account for running functions

resource "google_service_account" "function_identity" {
  account_id   = var.function_runner_account_id
  display_name = "Cloud Run Functions Service Account"
}

resource "google_project_iam_member" "function_firestore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.function_identity.email}"
}

# IAM resource for allowing API Gateway to invoke functions

resource "google_cloud_run_v2_service_iam_member" "api_gateway_invoker" {
  for_each = local.api_gateway_functions

  project  = var.project_id
  location = var.region
  name     = google_cloudfunctions2_function.golang_functions[each.key].name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.api_gateway_service_account}"
}

# IAM resource for allowing App Engine to invoke functions

resource "google_cloud_run_v2_service_iam_member" "app_engine_invoker" {
  for_each = local.app_engine_functions

  project  = var.project_id
  location = var.region
  name     = google_cloudfunctions2_function.nodejs_functions[each.key].name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.app_engine_service_account}"
}