resource "aws_amplify_app" "rexony" {
  name         = "rexony"
  repository   = "https://github.com/${var.github_org}/${var.fp_repo}"
  access_token = var.github_token

  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm install
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: dist
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json)$)([^.]+$)/>"
    target = "/index.html"
    status = "200"
  }

  environment_variables = {
    VITE_API_URL             = "https://${aws_api_gateway_rest_api.rexony.id}.execute-api.${var.aws_region}.amazonaws.com/prod"
    VITE_USER_POOL_ID        = aws_cognito_user_pool.rexony.id
    VITE_USER_POOL_CLIENT_ID = aws_cognito_user_pool_client.rexony.id
    VITE_AWS_REGION          = var.aws_region
  }

  tags = {
    Project = "rexony"
    Group   = "04"
  }
}

resource "aws_amplify_branch" "testtf" {
  app_id      = aws_amplify_app.rexony.id
  branch_name = "testtf"
  stage       = "PRODUCTION"
  enable_auto_build = false

  tags = {
    Project = "rexony"
    Group   = "04"
  }
}