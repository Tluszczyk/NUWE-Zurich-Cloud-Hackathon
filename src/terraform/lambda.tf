resource "aws_lambda_function" "add_customers" {
	function_name    = "add-customers"
	filename         = "files/add_customers_lambda.zip"
	handler          = "add_customers_lambda.lambda_handler"
	role             = aws_iam_role.add_customers_lambda.arn
	runtime          = "python3.10"

	environment {
		variables = {
			DYNAMO_CUSTOMERS_TABLE_NAME	= aws_dynamodb_table.customers.name

			ENDPOINT_URL              	= var.endpoint_url
			REGION_NAME               	= var.region
			ACCESS_KEY					= var.access_key
			SECRET_KEY					= var.secret_key
		}
	}
}

resource "aws_s3_bucket_notification" "lambda-s3-trigger" {
	bucket = aws_s3_bucket.customer_json_files.id

	lambda_function {
		lambda_function_arn = aws_lambda_function.add_customers.arn
		events              = ["s3:ObjectCreated:*"]
		filter_suffix       = ".json"
	}
}
