provider "aws" {
  region = "us-east-1"
}

data "archive_file" "lambda_zip" {
    type = "zip"

    output_path = "${path.module}/build/hello.zip"
    source_dir = "../src/hello"
}

data "archive_file" "lambda_generator" {
    type = "zip"

    output_path = "${path.module}/build/generator.zip"
    source_dir = "../src/generator"
}

resource "aws_dynamodb_table" "basic-dynamodb-table-2" {
  name           = "Request"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "TaxId"
  range_key      = "RequestId"


  stream_enabled = true
  stream_view_type = "KEYS_ONLY"

  attribute {
    name = "RequestId"
    type = "S"
  }

  attribute {
    name = "TaxId"
    type = "S"
  }

  attribute {
    name = "InvoiceNumber"
    type = "S"
  }

  global_secondary_index {
    name               = "TaxIdIndex"
    hash_key           = "TaxId"
    range_key          = "InvoiceNumber"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["RequestId"]
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "hdiomede-hello-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.my_bucket.bucket
  key = "hello.zip"

  source = data.archive_file.lambda_zip.output_path
  etag = filemd5(data.archive_file.lambda_zip.output_path)
}

resource "aws_s3_bucket_object" "lambda_generator_s3" {
  bucket = aws_s3_bucket.my_bucket.bucket
  key = "generator.zip"

  source = data.archive_file.lambda_generator.output_path
  etag = filemd5(data.archive_file.lambda_generator.output_path)
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

resource "aws_iam_role_policy" "dynamodb-lambda-policy" {
   name = "dynamodb_lambda_policy"
   role = aws_iam_role.lambda_role.id
   policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
           "Effect" : "Allow",
           "Action" : ["dynamodb:*"],
           "Resource" : "${aws_dynamodb_table.basic-dynamodb-table-2.stream_arn}"
        }
      ]
   })
}

resource "aws_lambda_function" "test_lambda_s3" {
  s3_bucket = aws_s3_bucket.my_bucket.id
  s3_key = aws_s3_bucket_object.lambda_hello_world.key
  
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  function_name = "hello_world_s3"
  role = aws_iam_role.lambda_role.arn

  handler = "hello.handler"
  runtime = "nodejs12.x"

  timeout = 300

  environment {
    variables = {
        CLIENT_SECRET = "123"
        ACCESS_KEY = "456"
    }
  }
}


resource "aws_lambda_function" "generator_lambda_s3" {
  s3_bucket = aws_s3_bucket.my_bucket.id
  s3_key = aws_s3_bucket_object.lambda_generator_s3.key
  
  source_code_hash = data.archive_file.lambda_generator.output_base64sha256
  
  function_name = "generator"
  role = aws_iam_role.lambda_role.arn

  handler = "index.handler"
  runtime = "nodejs12.x"

  timeout = 300

  environment {
    variables = {
        CLIENT_SECRET = "123"
        ACCESS_KEY = "456"
    }
  }
}