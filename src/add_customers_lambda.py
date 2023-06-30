import boto3
import json
import logging
import os


def retrieve_customers_from_s3(event: dict[str, any], config: dict[str, str], logger: logging.Logger) -> list[dict[str, any]]:
    '''
    Retrieves the user data from the S3 bucket and key specified in the event.
    @param event: The event that triggered this function.
    @param config: The configuration for the AWS services. For Localstack development it must contain the following keys:
        - aws_access_key_id
        - aws_secret_access_key
        - endpoint_url
        - region_name
    @param logger: The logger to use for logging.
    @return: The user data as a list of dictionaries.
    '''

    # Retrieve the S3 bucket and key from the event
    try:
        s3_bucket = event['Records'][0]['s3']['bucket']['name']
        s3_key = event['Records'][0]['s3']['object']['key']
    except Exception as e:
        logger.error("Error getting S3 bucket and key from event. Make sure event comes from S3 trigger.")
        raise e

    # Read the JSON file from S3
    try:
        s3_client = boto3.client(
            service_name='s3',
            **config
        )

        response = s3_client.get_object(Bucket=s3_bucket, Key=s3_key)
        
    except Exception as e:
        logger.error("Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.".format(s3_key, s3_bucket))
        raise e
    
    # Parse the JSON data
    try:
        json_data = response['Body'].read().decode('utf-8')
        user_data_list = json.loads(json_data)

    except Exception as e:
        logger.error("Unable to load JSON data from file {}. Make sure it exists and is valid.".format(s3_key))
        raise e

    return user_data_list


def put_items_to_dynamo(table_name: str, items: list[dict[str, any]], config: dict[str, str], logger: logging.Logger) -> None:
    '''
    Inserts the user data into the DynamoDB table.
    @param table_name: The name of the DynamoDB table to insert the data into.
    @param items: The user data to insert into the table.
    @param config: The configuration for the AWS services. For Localstack development it must contain the following keys:
        - aws_access_key_id
        - aws_secret_access_key
        - endpoint_url
        - region_name
    @param logger: The logger to use for logging.
    '''

    try:
        dynamodb = boto3.resource(
            service_name='dynamodb',
            **config
        )
        
        table = dynamodb.Table(table_name)
    
        for item in items:
            table.put_item(Item=item)

    except Exception as e:
        logger.error("Error putting items into DynamoDB table {}. Make sure the table exists and your region is correct.".format(table_name))
        raise e
    

def lambda_handler(event, context):

    # Retrieve environment variables
    dynamo_customers_table_name = os.environ['DYNAMO_CUSTOMERS_TABLE_NAME'] 

    # required by localstack
    config = {
        "aws_access_key_id"     : os.environ['ACCESS_KEY'],
        "aws_secret_access_key" : os.environ['SECRET_KEY'],
        "endpoint_url"          : os.environ['ENDPOINT_URL'],
        "region_name"           : os.environ['REGION_NAME']
    }

    # Set up logging
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    # Retrieve the user data from S3
    user_data_list = retrieve_customers_from_s3(event, config, logger)

    # Insert the user data into DynamoDB
    put_items_to_dynamo(dynamo_customers_table_name, user_data_list, config, logger)

    # Log the number of items added
    logger.info("Successfully added/updated {} records in DynamoDB table {}".format(len(user_data_list), dynamo_customers_table_name))