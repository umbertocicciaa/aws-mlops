import boto3

def lambda_handler(event, context):
    sm = boto3.client('sagemaker')
    
    model_name = event['model_name']
    endpoint_name = event['endpoint_name']

    
    # Create endpoint config
    sm.create_endpoint_config(
        EndpointConfigName=model_name + "-config",
        ProductionVariants=[
            {
                'VariantName': 'AllTraffic',
                'ModelName': model_name,
                'InitialInstanceCount': 1,
                'InstanceType': 'ml.m5.large',
            }
        ]
    )

    # Create or update endpoint
    try:
        sm.create_endpoint(
            EndpointName=endpoint_name,
            EndpointConfigName=model_name + "-config"
        )
    except sm.exceptions.ResourceInUse:
        sm.update_endpoint(
            EndpointName=endpoint_name,
            EndpointConfigName=model_name + "-config"
        )
    return {"status": "Deployed"}
