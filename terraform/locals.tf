locals {
  golang_functions = toset([
    "login",
    "signup",
    "create-link",
    "get-links-by-username",
    "get-link-by-id",
    "process-link",
    "send-email",
  ])

  nodejs_functions = toset([
    "post-click",
  ])

  api_gateway_functions = toset([
    "login",
    "signup",
    "create-link",
    "get-links-by-username",
    "get-link-by-id",
  ])

  app_engine_functions = toset([
    "post-click",
  ])

  pubsub_functions = toset([
    "post-click",
    "process-link",
    "send-email",
  ])

  all_functions = setunion(local.golang_functions, local.nodejs_functions)
}