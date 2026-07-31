# Single secret — holds both STRIPE_SECRET_KEY and FROM_EMAIL so both
# rexony-orders and rexony-payment lambdas can retrieve them with one call.
resource "aws_secretsmanager_secret" "backend" {
  name                    = "rexony/backend"
  description             = "Rexony Lambda secrets (Stripe, SES)"
  recovery_window_in_days = 0   # immediate deletion — fine for student project

  tags = {
    Project = "rexony"
    Group   = "04"
  }
}

resource "aws_secretsmanager_secret_version" "backend" {
  secret_id = aws_secretsmanager_secret.backend.id

  # Placeholder values — Terraform writes these on first apply only.
  # After that, ignore_changes means Terraform never overwrites real values
  # you set manually (or via CI) in the AWS console.
  secret_string = jsonencode({
    STRIPE_SECRET_KEY = "REPLACE_ME_WITH_ACTUAL_KEY"
    FROM_EMAIL        = var.from_email
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}