# ──────────────────────────────────────────────
# Locals: reusable CORS OPTIONS mock integration
# ──────────────────────────────────────────────
locals {
  cors_options_integration = {
    type = "MOCK"
    requestTemplates = {
      "application/json" = "{\"statusCode\": 200}"
    }
    responses = {
      default = {
        statusCode = "200"
        responseParameters = {
          "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
          "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
          "method.response.header.Access-Control-Allow-Origin"  = "'*'"
        }
        responseTemplates = {
          "application/json" = ""
        }
      }
    }
  }
}

# ──────────────────────────────────────────────
# REST API (OpenAPI body — full spec inline)
# ──────────────────────────────────────────────
resource "aws_api_gateway_rest_api" "rexony" {
  name        = "rexony-api"
  description = "Rexony e-commerce API — Group 04"

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "Rexony API"
      version = "1.0"
    }

    components = {
      securitySchemes = {
        CognitoAuth = {
          type                          = "apiKey"
          name                          = "Authorization"
          in                            = "header"
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

      # ── PRODUCTS ──────────────────────────────────────────────────────────────

      "/products" = {
        get = {
          summary = "List all products"
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.products.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary   = "CORS preflight"
          responses = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      "/admin/products" = {
        get = {
          summary  = "Admin: list all products"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.products.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary   = "CORS preflight"
          responses = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      "/product/{id}" = {
        get = {
          summary    = "Get product by ID"
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.products.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary    = "CORS preflight"
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      "/admin/product/new" = {
        post = {
          summary  = "Admin: create product"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.products.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary   = "CORS preflight"
          responses = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      "/admin/product/{id}" = {
        get = {
          summary    = "Admin: get product by ID"
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.products.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        put = {
          summary    = "Admin: update product"
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.products.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        delete = {
          summary    = "Admin: delete product"
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.products.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary    = "CORS preflight"
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      # ── REVIEWS ───────────────────────────────────────────────────────────────

      "/reviews" = {
        get = {
          summary = "Get reviews"
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.products.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary   = "CORS preflight"
          responses = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      "/review" = {
        put = {
          summary  = "Add or update review"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.products.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        delete = {
          summary  = "Delete review"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.products.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary   = "CORS preflight"
          responses = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      # ── ORDERS ────────────────────────────────────────────────────────────────

      "/order/new" = {
        post = {
          summary  = "Create order"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.orders.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary   = "CORS preflight"
          responses = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      "/orders/me" = {
        get = {
          summary  = "Get my orders"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.orders.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary   = "CORS preflight"
          responses = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      "/order/{id}/cancel" = {
        put = {
          summary    = "Cancel order"
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.orders.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary    = "CORS preflight"
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      "/admin/orders" = {
        get = {
          summary  = "Admin: list all orders"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.orders.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary   = "CORS preflight"
          responses = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      "/admin/order/{id}" = {
        put = {
          summary    = "Admin: update order status"
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.orders.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        delete = {
          summary    = "Admin: delete order"
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.orders.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary    = "CORS preflight"
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      # ── CART ──────────────────────────────────────────────────────────────────

      "/cart" = {
        get = {
          summary  = "Get cart"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.cart.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        post = {
          summary  = "Add item to cart"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.cart.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        put = {
          summary  = "Update cart item quantity"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.cart.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary   = "CORS preflight"
          responses = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      "/cart/clear" = {
        delete = {
          summary  = "Clear entire cart"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.cart.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary   = "CORS preflight"
          responses = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      "/cart/{productId}" = {
        delete = {
          summary    = "Remove item from cart"
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "productId", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.cart.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary    = "CORS preflight"
          parameters = [{ name = "productId", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      # ── PAYMENT ───────────────────────────────────────────────────────────────

      "/payment/checkout" = {
        post = {
          summary  = "Stripe checkout"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.payment.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary   = "CORS preflight"
          responses = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      # ── USERS (admin) ─────────────────────────────────────────────────────────

      "/admin/users" = {
        get = {
          summary  = "Admin: list all Cognito users"
          security = [{ CognitoAuth = [] }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.users.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary   = "CORS preflight"
          responses = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

      "/admin/user/{id}" = {
        get = {
          summary    = "Admin: get user by sub"
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.users.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        put = {
          summary    = "Admin: update user (role etc.)"
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.users.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        delete = {
          summary    = "Admin: disable/delete user"
          security   = [{ CognitoAuth = [] }]
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          "x-amazon-apigateway-integration" = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = aws_lambda_function.users.invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
        options = {
          summary    = "CORS preflight"
          parameters = [{ name = "id", in = "path", required = true, schema = { type = "string" } }]
          responses  = { "200" = { description = "OK" } }
          "x-amazon-apigateway-integration" = local.cors_options_integration
        }
      }

    } # end paths
  })  # end jsonencode

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Project = "rexony"
    Group   = "04"
  }
}

# ──────────────────────────────────────────────
# Gateway-level CORS headers on auth errors
# (without these, Cognito 401/403 responses
#  also strip CORS headers and confuse the browser)
# ──────────────────────────────────────────────
resource "aws_api_gateway_gateway_response" "unauthorized" {
  rest_api_id   = aws_api_gateway_rest_api.rexony.id
  response_type = "UNAUTHORIZED"
  status_code   = "401"
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

resource "aws_api_gateway_gateway_response" "access_denied" {
  rest_api_id   = aws_api_gateway_rest_api.rexony.id
  response_type = "ACCESS_DENIED"
  status_code   = "403"
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

resource "aws_api_gateway_gateway_response" "default_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.rexony.id
  response_type = "DEFAULT_5XX"
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

# ──────────────────────────────────────────────
# Deployment — retriggers whenever the body changes
# ──────────────────────────────────────────────
resource "aws_api_gateway_deployment" "rexony" {
  rest_api_id = aws_api_gateway_rest_api.rexony.id

  triggers = {
    redeployment = sha1(aws_api_gateway_rest_api.rexony.body)
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ──────────────────────────────────────────────
# CloudWatch log group for access logs
# ──────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/rexony"
  retention_in_days = 7

  tags = {
    Project = "rexony"
    Group   = "04"
  }
}

# ──────────────────────────────────────────────
# Stage: prod
# ──────────────────────────────────────────────
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.rexony.id
  rest_api_id   = aws_api_gateway_rest_api.rexony.id
  stage_name    = "prod"

  xray_tracing_enabled = false  # enable if you want X-Ray traces

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      ip                      = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationError        = "$context.integrationErrorMessage"
    })
  }

  tags = {
    Project = "rexony"
    Group   = "04"
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway,
    aws_api_gateway_deployment.rexony,
  ]
}

# ──────────────────────────────────────────────
# Lambda permissions — allow API Gateway to invoke
# ──────────────────────────────────────────────
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