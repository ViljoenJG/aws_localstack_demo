# -----------------------------------------------
# IAM Role for Lambda
# -----------------------------------------------
resource "aws_iam_role" "lambda_role" {
  name = "demo-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "lambda-dynamodb-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.items.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# -----------------------------------------------
# Package Lambda code
# -----------------------------------------------
data "archive_file" "python_lambda" {
  type        = "zip"
  source_file = "${path.module}/../../lambdas/read-items/handler.py"
  output_path = "${path.module}/../.build/python-lambda.zip"
}

data "archive_file" "node_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/write-items"
  output_path = "${path.module}/../.build/node-lambda.zip"
}

# -----------------------------------------------
# Lambda Functions
# -----------------------------------------------
resource "aws_lambda_function" "list_items" {
  function_name    = "list-items"
  filename         = data.archive_file.python_lambda.output_path
  source_code_hash = data.archive_file.python_lambda.output_base64sha256
  handler          = "handler.list_items"
  runtime          = "python3.13"
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.items.name
    }
  }
}

resource "aws_lambda_function" "get_item" {
  function_name    = "get-item"
  filename         = data.archive_file.python_lambda.output_path
  source_code_hash = data.archive_file.python_lambda.output_base64sha256
  handler          = "handler.get_item"
  runtime          = "python3.13"
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.items.name
    }
  }
}

resource "aws_lambda_function" "create_item" {
  function_name    = "create-item"
  filename         = data.archive_file.node_lambda.output_path
  source_code_hash = data.archive_file.node_lambda.output_base64sha256
  handler          = "handler.createItem"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.items.name
    }
  }
}

resource "aws_lambda_function" "delete_item" {
  function_name    = "delete-item"
  filename         = data.archive_file.node_lambda.output_path
  source_code_hash = data.archive_file.node_lambda.output_base64sha256
  handler          = "handler.deleteItem"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.items.name
    }
  }
}
