import streamlit as st
import pandas as pd
import requests
import json
import os
import matplotlib.pyplot as plt

# Constants
ENDPOINT_URL = os.environ.get("SAGEMAKER_ENDPOINT_URL")

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

# Make prediction
if st.button("Predict"):
    response = requests.post(ENDPOINT_URL, data=json.dumps(input_data), headers={"Content-Type": "application/json"})
    prediction = response.json()
    
    # Display prediction result
    st.subheader("Prediction Result")
    st.write(f"Predicted House Price: ${prediction['predictions'][0]:,.2f}")

    # Visualization
    st.subheader("Visualization")
    plt.figure(figsize=(10, 5))
    plt.bar(["Predicted Price"], [prediction['predictions'][0]], color='blue')
    plt.ylabel("Price in $")
    plt.title("Predicted House Price")
    st.pyplot(plt)