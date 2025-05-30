# Frontend

This project is a Streamlit application designed to make predictions using a SageMaker endpoint for a linear regression model trained on the California housing dataset using XGBoost.

## Project Structure

```txt
frontend
├── src
│   └── app.py          # Main entry point for the Streamlit application
│   └── requirements.txt     # List of dependencies required for the project
└── README.md            # Documentation for the project
```

## Setup Instructions

1. Clone the repository:

   ```sh
   git clone https://github.com/umbertocicciaa/aws-mlops.git
   cd frontend
   ```

2. Create a virtual environment (optional but recommended):

   ```sh
   python -m venv venv
   source venv/bin/activate  # On Windows use `venv\Scripts\activate`
   ```

3. Install the required dependencies:

   ```sh
   pip install -r requirements.txt
   ```

## Usage Guidelines

1. Start the Streamlit application:

   ```sh
   streamlit run src/app.py
   ```

2. Open your web browser and navigate to `http://localhost:8501` to access the application.

3. Input the features required for prediction based on the California housing dataset and submit the form to receive predictions.

## California Housing Dataset

The California housing dataset is a well-known dataset used for regression tasks. It contains various features such as median income, housing age, and average rooms per household, which are used to predict the median house value.

## SageMaker Endpoint

This application communicates with a SageMaker endpoint that hosts a linear regression model trained on the California housing dataset using XGBoost. Ensure that the endpoint is properly configured and running before using the application.
