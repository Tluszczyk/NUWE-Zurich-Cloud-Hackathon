provider "aws" {
    region      = var.region

    # LocalStack
    access_key                  = var.access_key
    secret_key                  = var.secret_key

    s3_use_path_style           = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true

    default_tags {
        tags = {
            Application = var.application
            Environment = var.environment
        }
    }
}

terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
        }
    }
}