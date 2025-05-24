def preprocess_input(features):
    # Function to preprocess input features for the SageMaker endpoint
    # Convert features to the appropriate format (e.g., list or numpy array)
    return [features]

def call_sagemaker_endpoint(input_data, endpoint_name):
    import requests
    import json

    # Function to call the SageMaker endpoint and get predictions
    response = requests.post(
        f"https://runtime.sagemaker.us-west-2.amazonaws.com/endpoints/{endpoint_name}/invocations",
        headers={"Content-Type": "application/json"},
        data=json.dumps(input_data)
    )
    
    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"Error calling SageMaker endpoint: {response.text}")

def visualize_results(predictions):
    import matplotlib.pyplot as plt

    # Function to visualize the prediction results
    plt.figure(figsize=(10, 5))
    plt.bar(range(len(predictions)), predictions, color='blue')
    plt.xlabel('Predictions')
    plt.ylabel('Value')
    plt.title('Predicted Housing Prices')
    plt.show()