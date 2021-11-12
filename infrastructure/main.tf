provider "aws" {
  region = "us-east-1"
}

data "archive_file" "lambda_zip" {
    type = "zip"

    output_path = "${path.module}/build/hello.zip"
    source_dir = "../src/hello"
}

resource "aws_lambda_function" "test_lambda" {
  filename = "${path.module}/build/hello.zip"
  function_name = "hello_world"
  role = aws_iam_role.lambda_role.arn
  handler = "hello.handler"
  runtime = "nodejs12.x"
  environment {
    variables = {
        CLIENT_SECRET = "123"
        ACCESS_KEY = "456"
    }
  }
}