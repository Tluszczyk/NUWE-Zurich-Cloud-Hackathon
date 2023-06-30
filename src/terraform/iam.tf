resource "aws_iam_role" "add_customers_lambda" {
	name        = "AddCustomerLambdaRole"
	description = "IAM role for the add_customers_lambda function"

	assume_role_policy = jsonencode({
		Version   = "2012-10-17"
		Statement = [
			{
				Action    = "sts:AssumeRole"
				Effect    = "Allow"
				Principal = {
					Service = "lambda.amazonaws.com"
				}
			}
		]
	})
}

resource "aws_iam_policy" "add_customers_lambda" {
	name   = "AddCustomerLambdaPolicy"
	description = "IAM policy for the add_customers_lambda function"

	policy = jsonencode({
		Version   = "2012-10-17"
		Statement = [
			{
				Effect   = "Allow"
				Action   = ["s3:GetObject"]
				Resource = [
					format("arn:aws:s3:::%s", aws_s3_bucket.customer_json_files.id),
					format("arn:aws:s3:::%s/*", aws_s3_bucket.customer_json_files.id)
				]
			},
			{
				Effect   = "Allow"
				Action   = ["dynamodb:PutItem"]
				Resource = [
					format("arn:aws:dynamodb:%s:%s:table/%s", var.region, var.account_id, aws_dynamodb_table.customers.name)
				]
			}
		]
	})
}

resource "aws_iam_role_policy_attachment" "add_customers_lambda" {
	role       = aws_iam_role.add_customers_lambda.name
	policy_arn = aws_iam_policy.add_customers_lambda.arn
}



resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "CloudWatchLogsWriteAccess"
  description = "Allows Lambda function to write to CloudWatch Logs"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "CloudWatchLogsWriteAccess"
        Effect    = "Allow"
        Action    = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource  = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_logs" {
  role       = aws_iam_role.add_customers_lambda.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}
