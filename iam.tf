# ── Shared assume-role policy for Lambda ──────────────────────────────────────
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ── Shared policy documents ───────────────────────────────────────────────────
data "aws_iam_policy_document" "logs" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "dynamodb" {
  statement {
    effect  = "Allow"
    actions = ["dynamodb:*"]
    resources = [
      aws_dynamodb_table.products.arn,
      aws_dynamodb_table.orders.arn,
      aws_dynamodb_table.cart.arn,
      "${aws_dynamodb_table.orders.arn}/index/*",
    ]
  }
}

data "aws_iam_policy_document" "secrets" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:rexony/backend*"]
  }
}

data "aws_iam_policy_document" "ses" {
  statement {
    effect    = "Allow"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cognito_admin" {
  statement {
    effect  = "Allow"
    actions = [
      "cognito-idp:ListUsers",
      "cognito-idp:AdminGetUser",
      "cognito-idp:AdminUpdateUserAttributes",
      "cognito-idp:AdminDeleteUser"
    ]
    resources = [aws_cognito_user_pool.rexony.arn]
  }
}

data "aws_iam_policy_document" "ddb_streams" {
  statement {
    effect  = "Allow"
    actions = [
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListStreams"
    ]
    resources = ["${aws_dynamodb_table.orders.arn}/stream/*"]
  }
}

# ── rexony-orders ─────────────────────────────────────────────────────────────
resource "aws_iam_role" "orders" {
  name               = "rexony-orders-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "orders_logs" {
  role   = aws_iam_role.orders.id
  policy = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy" "orders_dynamodb" {
  role   = aws_iam_role.orders.id
  policy = data.aws_iam_policy_document.dynamodb.json
}

resource "aws_iam_role_policy" "orders_secrets" {
  role   = aws_iam_role.orders.id
  policy = data.aws_iam_policy_document.secrets.json
}

resource "aws_iam_role_policy" "orders_ses" {
  role   = aws_iam_role.orders.id
  policy = data.aws_iam_policy_document.ses.json
}

# ── rexony-payment ────────────────────────────────────────────────────────────
resource "aws_iam_role" "payment" {
  name               = "rexony-payment-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "payment_logs" {
  role   = aws_iam_role.payment.id
  policy = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy" "payment_secrets" {
  role   = aws_iam_role.payment.id
  policy = data.aws_iam_policy_document.secrets.json
}

# ── rexony-products ───────────────────────────────────────────────────────────
resource "aws_iam_role" "products" {
  name               = "rexony-products-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "products_logs" {
  role   = aws_iam_role.products.id
  policy = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy" "products_dynamodb" {
  role   = aws_iam_role.products.id
  policy = data.aws_iam_policy_document.dynamodb.json
}

# ── rexony-cart ───────────────────────────────────────────────────────────────
resource "aws_iam_role" "cart" {
  name               = "rexony-cart-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "cart_logs" {
  role   = aws_iam_role.cart.id
  policy = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy" "cart_dynamodb" {
  role   = aws_iam_role.cart.id
  policy = data.aws_iam_policy_document.dynamodb.json
}

# ── rexony-users ──────────────────────────────────────────────────────────────
resource "aws_iam_role" "users" {
  name               = "rexony-users-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "users_logs" {
  role   = aws_iam_role.users.id
  policy = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy" "users_cognito" {
  role   = aws_iam_role.users.id
  policy = data.aws_iam_policy_document.cognito_admin.json
}

# ── rexony-sns ────────────────────────────────────────────────────────────────
resource "aws_iam_role" "sns" {
  name               = "rexony-sns-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "sns_logs" {
  role   = aws_iam_role.sns.id
  policy = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy" "sns_ses" {
  role   = aws_iam_role.sns.id
  policy = data.aws_iam_policy_document.ses.json
}

resource "aws_iam_role_policy" "sns_streams" {
  role   = aws_iam_role.sns.id
  policy = data.aws_iam_policy_document.ddb_streams.json
}

# ── GitHub Actions OIDC ───────────────────────────────────────────────────────
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

locals {
  github_oidc_arn = aws_iam_openid_connect_provider.github.arn
  oidc_conditions = {
    StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
  }
}

resource "aws_iam_role" "github_be" {
  name = "rexony-github-backend-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.github_oidc_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = merge(local.oidc_conditions, {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:*/${var.be_repo}*:environment:prod",
            "repo:*/${var.be_repo}*:environment:new-infra"
          ]
        }
      })
    }]
  })
}

resource "aws_iam_role_policy" "github_be" {
  role = aws_iam_role.github_be.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["lambda:UpdateFunctionCode", "lambda:InvokeFunction"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "github_fp" {
  name = "rexony-github-frontend-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.github_oidc_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = merge(local.oidc_conditions, {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:*/${var.fp_repo}*:environment:prod",
            "repo:*/${var.fp_repo}*:environment:new-infra",
            "repo:*/${var.fp_repo}*:environment:tfinfra"
          ]
        }
      })
    }]
  })
}

resource "aws_iam_role_policy" "github_fp" {
  role = aws_iam_role.github_fp.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["amplify:StartJob", "amplify:GetJob"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "github_iac" {
  name = "rexony-github-infra-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = local.github_oidc_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = merge(local.oidc_conditions, {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:*/${var.iac_repo}*:environment:prod",
            "repo:*/${var.iac_repo}*:environment:new-infra"
          ]
        }
      })
    }]
  })
}

resource "aws_iam_role_policy_attachment" "github_iac_admin" {
  role       = aws_iam_role.github_iac.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}