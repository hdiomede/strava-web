resource "aws_iam_role_policy" "lambda_policy" {
  name = "hello_lambda_policy"
  role = aws_iam_role.lambda_role.id
  policy = file("iam/lambda_policy.json")
}

resource "aws_iam_role" "lambda_role" {
  name = "hello_lambda_role"
  assume_role_policy = file("iam/lambda_assume_role_policy.json")
}
