output "api_gateway_url" {
  value       = "https://${aws_api_gateway_rest_api.rexony.id}.execute-api.${var.aws_region}.amazonaws.com/prod"
  description = "Update aws-config.js API_BASE with this value"
}

output "cognito_user_pool_id" {
  value       = aws_cognito_user_pool.rexony.id
  description = "Update aws-config.js COGNITO_USER_POOL_ID with this value"
}

output "cognito_client_id" {
  value       = aws_cognito_user_pool_client.rexony.id
  description = "Update aws-config.js COGNITO_CLIENT_ID with this value"
}

output "amplify_app_id" {
  value       = aws_amplify_app.rexony.id
  description = "Set as AMPLIFY_APP_ID in FP repo GitHub environment"
}

output "amplify_url" {
  value       = "https://testtf.${aws_amplify_app.rexony.default_domain}"
  description = "Frontend URL — update aws-config.js and Cognito callback if needed"
}

output "github_be_role_arn" {
  value       = aws_iam_role.github_be.arn
  description = "Set as AWS_ROLE_ARN in BE repo GitHub prod environment"
}

output "github_fp_role_arn" {
  value       = aws_iam_role.github_fp.arn
  description = "Set as AWS_ROLE_ARN in FP repo GitHub prod environment"
}

output "github_iac_role_arn" {
  value       = aws_iam_role.github_iac.arn
  description = "Set as AWS_ROLE_ARN in IAC repo GitHub prod environment"
}

output "manual_steps" {
  value = <<-EOT
    After terraform apply:
    1. Set Secrets Manager secret 'rexony/backend':
       { "STRIPE_SECRET_KEY": "sk_test_...", "FROM_EMAIL": "${var.from_email}" }
    2. Verify SES email ${var.from_email} (check inbox for verification link)
    3. Update aws-config.js in FP repo with new API_BASE, COGNITO_USER_POOL_ID, COGNITO_CLIENT_ID
    4. Set GitHub repo environment variables:
       BE repo  → AWS_ROLE_ARN = ${aws_iam_role.github_be.arn}, AWS_REGION = ${var.aws_region}
       FP repo  → AWS_ROLE_ARN = ${aws_iam_role.github_fp.arn}, AWS_REGION = ${var.aws_region}, AMPLIFY_APP_ID = ${aws_amplify_app.rexony.id}
       IAC repo → AWS_ROLE_ARN = ${aws_iam_role.github_iac.arn}, AWS_REGION = ${var.aws_region}
    5. Push to main on BE and FP repos to deploy Lambda code and frontend
  EOT
}