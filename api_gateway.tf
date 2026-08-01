# ──────────────────────────────────────────────────────────────
# Locals
# ──────────────────────────────────────────────────────────────
locals {
  # Standard MOCK CORS OPTIONS integration — reused on every path
  cors_mock = {
    type = "MOCK"
    requestTemplates = { "application/json" = "{\"statusCode\": 200}" }
    responses = {
      default = {
        statusCode = "200"
        responseParameters = {
          "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
          "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
          "method.response.header.Access-Control-Allow-Origin"  = "'*'"
        }
        responseTemplates = { "application/json" = "" }
      }
    }
  }

  # Lambda proxy integration helpers — one per function
  int_products = {
    type                = "aws_proxy"
    httpMethod          = "POST"
    uri                 = aws_lambda_function.products.invoke_arn
    passthroughBehavior = "when_no_match"
    timeoutInMillis     = 29000
    contentHandling     = "CONVERT_TO_TEXT"
  }
  int_orders = {
    type                = "aws_proxy"
    httpMethod          = "POST"
    uri                 = aws_lambda_function.orders.invoke_arn
    passthroughBehavior = "when_no_match"
    timeoutInMillis     = 29000
    contentHandling     = "CONVERT_TO_TEXT"
  }
  int_cart = {
    type                = "aws_proxy"
    httpMethod          = "POST"
    uri                 = aws_lambda_function.cart.invoke_arn
    passthroughBehavior = "when_no_match"
    timeoutInMillis     = 29000
    contentHandling     = "CONVERT_TO_TEXT"
  }
  int_payment = {
    type                = "aws_proxy"
    httpMethod          = "POST"
    uri                 = aws_lambda_function.payment.invoke_arn
    passthroughBehavior = "when_no_match"
    timeoutInMillis     = 29000
    contentHandling     = "CONVERT_TO_TEXT"
  }
  int_users = {
    type                = "aws_proxy"
    httpMethod          = "POST"
    uri                 = aws_lambda_function.users.invoke_arn
    passthroughBehavior = "when_no_match"
    timeoutInMillis     = 29000
    contentHandling     = "CONVERT_TO_TEXT"
  }
}

# ──────────────────────────────────────────────────────────────
# REST API
# ──────────────────────────────────────────────────────────────
resource "aws_api_gateway_rest_api" "rexony" {
  name        = "rexony-api"
  description = "Rexony e-commerce API — Group 04"

  body = jsonencode({
    openapi = "3.0.1"
    info = { title = "rexony-api", version = "1.0" }

    "x-amazon-apigateway-security-policy" = "TLS_1_0"

    "x-amazon-apigateway-gateway-responses" = {
      DEFAULT_4XX = {
        responseParameters = {
          "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
        }
        responseTemplates = {
          "application/json" = "{\"message\":$context.error.messageString}"
        }
      }
      DEFAULT_5XX = {
        responseParameters = {
          "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
          "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
        }
        responseTemplates = {
          "application/json" = "{\"message\":$context.error.messageString}"
        }
      }
      UNAUTHORIZED = {
        statusCode = "401"
        responseParameters = {
          "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
          "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
        }
      }
    }

    components = {
      schemas = {
        Empty = { title = "Empty Schema", type = "object" }
      }
      securitySchemes = {
        CognitoAuth = {
          type                           = "apiKey"
          name                           = "Authorization"
          in                             = "header"
          "x-amazon-apigateway-authtype" = "cognito_user_pools"
          "x-amazon-apigateway-authorizer" = {
            type           = "cognito_user_pools"
            providerARNs   = [aws_cognito_user_pool.rexony.arn]
            identitySource = "method.request.header.Authorization"
          }
        }
      }
    }

    paths = {

      # ── PRODUCTS ────────────────────────────────────────────

      "/products" = {
        get     = { "x-amazon-apigateway-integration" = local.int_products }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/product/{id}" = {
        get = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = local.int_products
        }
        options = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_mock
        }
      }

      "/contact" = {
        post    = { "x-amazon-apigateway-integration" = local.int_orders }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/reviews" = {
        get     = { "x-amazon-apigateway-integration" = local.int_products }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/review" = {
        put     = { "x-amazon-apigateway-integration" = local.int_products }
        delete  = { "x-amazon-apigateway-integration" = local.int_products }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      # ── ADMIN PRODUCTS ───────────────────────────────────────

      "/admin/products" = {
        get = {
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = local.int_products
        }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/admin/product" = {
        get = {
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = local.int_products
        }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/admin/product/new" = {
        post = {
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = local.int_products
        }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/admin/product/{id}" = {
        get = {
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = local.int_products
        }
        put = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = local.int_products
        }
        delete = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = local.int_products
        }
        options = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_mock
        }
      }

      # ── ORDERS ───────────────────────────────────────────────

      "/order"   = { options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock } }
      "/orders"  = { options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock } }

      "/order/new" = {
        post    = { "x-amazon-apigateway-integration" = local.int_orders }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/orders/me" = {
        get = {
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = local.int_orders
        }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/order/{id}" = {
        options = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_mock
        }
      }

      "/order/{id}/cancel" = {
        put = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = local.int_orders
        }
        options = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_mock
        }
      }

      "/admin/orders" = {
        get = {
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = local.int_orders
        }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/admin/order" = {
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/admin/order/{id}" = {
        put = {
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = local.int_orders
        }
        delete = {
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = local.int_orders
        }
        options = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_mock
        }
      }

      "/admin/order/{id}/cancel" = {
        put = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = local.int_orders
        }
        options = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_mock
        }
      }

      # ── CART ─────────────────────────────────────────────────

      "/cart" = {
        get = {
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = local.int_cart
        }
        post = {
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = local.int_cart
        }
        put = {
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = local.int_cart
        }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/cart/clear" = {
        delete = {
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = local.int_cart
        }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/cart/{productId}" = {
        delete = {
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "productId", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = local.int_cart
        }
        options = {
          parameters = [{ name = "productId", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_mock
        }
      }

      # ── PAYMENT ──────────────────────────────────────────────

      "/payment" = {
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/payment/checkout" = {
        post    = { "x-amazon-apigateway-integration" = local.int_payment }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      # ── USERS (admin) ─────────────────────────────────────────

      "/admin/user" = {
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/admin/users" = {
        get = {
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = local.int_users
        }
        options = { responses = { "200" = { description = "OK" } }, "x-amazon-apigateway-integration" = local.cors_mock }
      }

      "/admin/user/{id}" = {
        get = {
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = local.int_users
        }
        put = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = local.int_users
        }
        delete = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = local.int_users
        }
        options = {
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_mock
        }
      }

    } # end paths
  })  # end jsonencode

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = { Project = "rexony", Group = "04" }
}

# ── Deployment ───────────────────────────────────────────────
resource "aws_api_gateway_deployment" "rexony" {
  rest_api_id = aws_api_gateway_rest_api.rexony.id

  triggers = {
    redeployment = sha1(aws_api_gateway_rest_api.rexony.body)
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── CloudWatch log group ─────────────────────────────────────
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/rexony"
  retention_in_days = 7
  tags              = { Project = "rexony", Group = "04" }
}

# ── CloudWatch account-level role (required for API GW logging) ──
resource "aws_iam_role" "api_gateway_cloudwatch" {
  name = "rexony-apigw-cloudwatch-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "apigateway.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch" {
  role       = aws_iam_role.api_gateway_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "rexony" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

# ── Stage ────────────────────────────────────────────────────
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.rexony.id
  rest_api_id   = aws_api_gateway_rest_api.rexony.id
  stage_name    = "prod"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId        = "$context.requestId"
      ip               = "$context.identity.sourceIp"
      requestTime      = "$context.requestTime"
      httpMethod       = "$context.httpMethod"
      resourcePath     = "$context.resourcePath"
      status           = "$context.status"
      responseLength   = "$context.responseLength"
      integrationError = "$context.integrationErrorMessage"
    })
  }

  tags = { Project = "rexony", Group = "04" }

  depends_on = [aws_api_gateway_account.rexony]
}

# ── Lambda invoke permissions ────────────────────────────────
resource "aws_lambda_permission" "apigw_products" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.products.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rexony.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_orders" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.orders.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rexony.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_cart" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cart.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rexony.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_payment" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.payment.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rexony.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_users" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.users.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rexony.execution_arn}/*/*"
}