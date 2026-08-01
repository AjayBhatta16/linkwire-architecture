locals {
  golang_functions = toset([
    "login",
    "signup",
    "create-link",
    "get-links-by-username",
    "get-link-by-id",
    "post-password-reset-request",
    "update-user-password",
    "validate-password-reset-request",
    "post-user-agreed-to-terms",
    "post-contact-request",
    "logout",
  ])

  golang_pubsub_functions = toset([
    "process-link",
    "send-email",
  ])

  nodejs_functions = toset([
    "get-device-info",
  ])

  nodejs_pubsub_functions = toset([
    "post-click",
  ])

  api_gateway_functions = toset([
    "login",
    "signup",
    "create-link",
    "get-links-by-username",
    "get-link-by-id",
    "post-password-reset-request",
    "update-user-password",
    "validate-password-reset-request",
    "post-user-agreed-to-terms",
    "post-contact-request",
    "logout",
  ])

  app_engine_functions = toset([
    "post-click",
  ])

  pubsub_functions = toset([
    "post-click",
    "process-link",
    "send-email",
  ])
}