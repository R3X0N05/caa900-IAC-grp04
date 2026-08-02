resource "aws_cognito_user_pool" "rexony" {
  name                = "rexony-user-pool"
  deletion_protection = "INACTIVE"

  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  schema {
    name                     = "custom:role"
    attribute_data_type      = "String"
    mutable                  = true
    required                 = false
    developer_only_attribute = false
    string_attribute_constraints {
      min_length = 0
      max_length = 256
    }
  }

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "rexony" {
  name         = "rexony-users"
  user_pool_id = aws_cognito_user_pool.rexony.id

  refresh_token_validity = 5
  access_token_validity  = 60
  id_token_validity      = 60

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  supported_identity_providers         = ["COGNITO"]
  callback_urls                        = ["https://localhost:3000/"]
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "phone"]
  allowed_oauth_flows_user_pool_client = true
  prevent_user_existence_errors        = "ENABLED"
  enable_token_revocation              = true
}