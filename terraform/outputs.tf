output "function_urls" {
  description = "HTTPS trigger URLs for all functions"
  value = merge(
    {
      for name, fn in google_cloudfunctions2_function.golang_functions :
      name => fn.service_config[0].uri
    },
    {
      for name, fn in google_cloudfunctions2_function.nodejs_functions :
      name => fn.service_config[0].uri
    }
  )
}