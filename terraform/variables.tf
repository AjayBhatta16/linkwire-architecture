variable project_id {
  type        = string
  default     = ""
  description = "GCP Project ID"
}

variable region {
  type        = string
  default     = ""
  description = "GCP Region"
}

variable function_src_bucket_name {
  type        = string
  default     = ""
  description = "GCS bucket name for Cloud Run function source code"
}

variable function_runner_account_id {
  type        = string
  default     = ""
  description = "ID for Service Account to run functions"
}

variable terraform_state_bucket_name {
  type        = string
  default     = ""
  description = "GCS bucket name for Terraform state storage"
}

variable api_gateway_service_account {
  description = "Service account email used by the existing API Gateway"
  default     = ""
  type        = string
}

variable app_engine_service_account {
  description = "Service account email used by the existing App Engine app"
  default     = ""
  type        = string
}