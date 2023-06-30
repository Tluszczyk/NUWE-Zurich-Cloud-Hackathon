variable "application" {
    type = string
    description = "name of the application"
}

variable "environment" {
    type = string
    description = "type of the deployment environment"
    
    validation {
        condition = can(regex("^(dev|test|prod)$", var.environment))
        error_message = "environment must be either dev, test or prod"
    }
}

variable "region" {
    type = string
    description = "name of the deployment AWS region"
}

variable "account_id" {
    type = string
    description = "id of the stack owner's account"
}

variable "access_key" {
    type = string
    description = "access key of the stack owner's account"
}

variable "secret_key" {
    type = string
    description = "secret key of the stack owner's account"
}

variable "endpoint_url" {
    type = string
    description = "endpoint url of the stack owner's account"
}