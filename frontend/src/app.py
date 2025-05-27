import streamlit as st
import json
import os
import matplotlib.pyplot as plt
from botocore.exceptions import BotoCoreError
import boto3

# Constants
REGION_NAME = os.environ.get("AWS_DEFAULT_REGION")
ENDPOINT_NAME = os.environ.get("SAGEMAKER_ENDPOINT_NAME")

# Streamlit app title
st.title("California Housing Price Prediction")

# User input for features
st.header("Input Features")
med_inc = st.number_input("Median Income", min_value=0.0, max_value=10.0, value=3.0)
house_age = st.number_input("House Age", min_value=0, max_value=100, value=20)
avg_rooms = st.number_input("Average Rooms", min_value=0, max_value=100, value=5)
avg_bedrooms = st.number_input("Average Bedrooms", min_value=0, max_value=100, value=2)
population = st.number_input("Population", min_value=0, max_value=100000, value=1000)
avg_occupancy = st.number_input("Average Occupancy", min_value=0.0, max_value=10.0, value=3.0)
latitude = st.number_input("Latitude", min_value=-90.0, max_value=90.0, value=37.0)
longitude = st.number_input("Longitude", min_value=-180.0, max_value=180.0, value=-119.0)

# Prepare input data for prediction
input_data = {
    "instances": [
        {
            "med_inc": med_inc,
            "house_age": house_age,
            "avg_rooms": avg_rooms,
            "avg_bedrooms": avg_bedrooms,
            "population": population,
            "avg_occupancy": avg_occupancy,
            "latitude": latitude,
            "longitude": longitude
        }
    ]
}

csv_input = f"{med_inc},{house_age},{avg_rooms},{avg_bedrooms},{population},{avg_occupancy},{latitude},{longitude}"

print("Selected Input Features:", input_data["instances"][0])

if st.button("Predict"):
    with st.spinner("Predicting..."):
        try:
            runtime = boto3.client("runtime.sagemaker")
            response = runtime.invoke_endpoint(
                EndpointName=ENDPOINT_NAME,
                ContentType="text/csv",
                Body=csv_input
            )
            prediction_raw = response["Body"].read().decode()
            try:
                prediction = json.loads(prediction_raw)
                if isinstance(prediction, dict) and "predictions" in prediction:
                    predicted_price = prediction["predictions"][0]
                elif isinstance(prediction, list):
                    predicted_price = prediction[0]
                else:
                    predicted_price = prediction
            except Exception:
                predicted_price = float(prediction_raw)
        except BotoCoreError as e:
            st.error(f"Error: {e}")
            predicted_price = 0

    # Display prediction result
    st.subheader("Prediction Result")
    st.write(f"Predicted House Price: ${predicted_price:,.2f}")