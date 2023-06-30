# Create Customers table
resource "aws_dynamodb_table" "customers" {
	name           = "Customers"
	billing_mode   = "PAY_PER_REQUEST"
	hash_key       = "id"

	attribute {
		name = "id"
		type = "S"
	}

	# Other attributes omitted for brevity
}