import boto3
import os

def handler(event, context):
    glue = boto3.client('glue')
    trigger_name = os.environ.get('GLUE_TRIGGER_NAME')

    try:
        params = {
            'Name': trigger_name
        }
        glue.start_trigger(**params)
        return {
            'statusCode': 200,
            'body': 'Successfully triggered Glue workflow'
        }
    except Exception as error:
        print(f'Error starting Glue trigger: {error}')
        raise error