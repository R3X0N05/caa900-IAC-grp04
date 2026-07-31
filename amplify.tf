resource "aws_amplify_app" "rexony" {
  name         = "rexony"
  repository   = "https://github.com/${var.github_org}/${var.fp_repo}"
  access_token = var.github_token

  # Vite / React build spec — update baseDirectory if you use CRA (build/) or Next.js (.next/)
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

  # SPA routing: send any path that isn't a static file to index.html
  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json)$)([^.]+$)/>"
    target = "/index.html"
    status = "200"
  }

  # These become VITE_* env vars inside the Amplify build container.
  # Update the key names to match whatever your frontend code actually reads.
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

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.rexony.id
  branch_name = "main"
  stage       = "PRODUCTION"

  # false = Amplify does NOT auto-build on push;
  # the FP repo's own GitHub Actions workflow calls
  # `aws amplify start-job` to trigger a build after deploying code.
  # Flip to true if you'd rather let Amplify handle its own deployments.
  enable_auto_build = false

  tags = {
    Project = "rexony"
    Group   = "04"
  }
}