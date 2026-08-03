data "archive_file" "placeholder" {
  type        = "zip"
  output_path = "/tmp/placeholder.zip"
  source {
    content  = "export const handler = async () => ({ statusCode: 200, headers: { 'Access-Control-Allow-Origin': '*' }, body: JSON.stringify({ message: 'Pending CI/CD deployment' }) });"
    filename = "index.mjs"
  }
}

locals {
  lambda_defaults = {
    runtime     = "nodejs22.x"
    handler     = "index.handler"
    timeout     = 3
    memory_size = 128
    filename    = data.archive_file.placeholder.output_path
    source_hash = data.archive_file.placeholder.output_base64sha256
  }
}

resource "aws_lambda_function" "orders" {
  function_name    = "rexony-orders"
  role             = aws_iam_role.orders.arn
  runtime          = local.lambda_defaults.runtime
  handler          = local.lambda_defaults.handler
  timeout          = local.lambda_defaults.timeout
  memory_size      = local.lambda_defaults.memory_size
  filename         = local.lambda_defaults.filename
  source_code_hash = local.lambda_defaults.source_hash
  lifecycle { ignore_changes = [filename, source_code_hash] }
}

resource "aws_lambda_function" "payment" {
  function_name    = "rexony-payment"
  role             = aws_iam_role.payment.arn
  runtime          = local.lambda_defaults.runtime
  handler          = local.lambda_defaults.handler
  timeout          = local.lambda_defaults.timeout
  memory_size      = local.lambda_defaults.memory_size
  filename         = local.lambda_defaults.filename
  source_code_hash = local.lambda_defaults.source_hash

  environment {
    variables = {
      FRONTEND_URL = "https://testtf.${aws_amplify_app.rexony.default_domain}"
    }
  }

  lifecycle { ignore_changes = [filename, source_code_hash] }
}

resource "aws_lambda_function" "products" {
  function_name    = "rexony-products"
  role             = aws_iam_role.products.arn
  runtime          = local.lambda_defaults.runtime
  handler          = local.lambda_defaults.handler
  timeout          = local.lambda_defaults.timeout
  memory_size      = local.lambda_defaults.memory_size
  filename         = local.lambda_defaults.filename
  source_code_hash = local.lambda_defaults.source_hash
  lifecycle { ignore_changes = [filename, source_code_hash] }
}

resource "aws_lambda_function" "cart" {
  function_name    = "rexony-cart"
  role             = aws_iam_role.cart.arn
  runtime          = local.lambda_defaults.runtime
  handler          = local.lambda_defaults.handler
  timeout          = local.lambda_defaults.timeout
  memory_size      = local.lambda_defaults.memory_size
  filename         = local.lambda_defaults.filename
  source_code_hash = local.lambda_defaults.source_hash
  lifecycle { ignore_changes = [filename, source_code_hash] }
}

resource "aws_lambda_function" "users" {
  function_name    = "rexony-users"
  role             = aws_iam_role.users.arn
  runtime          = local.lambda_defaults.runtime
  handler          = local.lambda_defaults.handler
  timeout          = local.lambda_defaults.timeout
  memory_size      = local.lambda_defaults.memory_size
  filename         = local.lambda_defaults.filename
  source_code_hash = local.lambda_defaults.source_hash
  lifecycle { ignore_changes = [filename, source_code_hash] }
}

resource "aws_lambda_function" "sns" {
  function_name    = "rexony-sns"
  role             = aws_iam_role.sns.arn
  runtime          = local.lambda_defaults.runtime
  handler          = local.lambda_defaults.handler
  timeout          = local.lambda_defaults.timeout
  memory_size      = local.lambda_defaults.memory_size
  filename         = local.lambda_defaults.filename
  source_code_hash = local.lambda_defaults.source_hash
  environment {
    variables = { FROM_EMAIL = var.from_email }
  }
  lifecycle { ignore_changes = [filename, source_code_hash] }
}

# DynamoDB Streams → rexony-sns
resource "aws_lambda_event_source_mapping" "orders_stream" {
  event_source_arn  = aws_dynamodb_table.orders.stream_arn
  function_name     = aws_lambda_function.sns.arn
  starting_position = "LATEST"
  filter_criteria {
    filter { pattern = jsonencode({ eventName = ["INSERT"] }) }
  }
}