# SES email identity — Terraform creates the identity, but AWS sends a
# verification email to the address. The human must click that link before
# SES will actually send mail from this address.
resource "aws_ses_email_identity" "from_email" {
  email = var.from_email
}