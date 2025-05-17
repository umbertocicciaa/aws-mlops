import json
import os
import tarfile
import pandas as pd
import numpy as np
import xgboost as xgb
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

# Set paths
model_path = '/opt/ml/processing/input/model'
test_path = '/opt/ml/processing/input/test'
output_path = '/opt/ml/processing/output/evaluation'

# Create output directory
os.makedirs(output_path, exist_ok=True)

# Extract the model
for file in os.listdir(model_path):
    if file.endswith('.tar.gz'):
        model_file = os.path.join(model_path, file)
        with tarfile.open(model_file) as tar:
            tar.extractall(path=model_path)
            
# Load the model
model = xgb.Booster()
model.load_model(os.path.join(model_path, 'xgboost-model'))

# Load test data
test_file = os.path.join(test_path, 'test.csv')
test_data = pd.read_csv(test_file, header=None)

# Separate features and target
X_test = test_data.iloc[:, :-1]
y_test = test_data.iloc[:, -1]

# Convert to DMatrix for XGBoost
dtest = xgb.DMatrix(X_test)

# Make predictions
predictions = model.predict(dtest)

# Calculate metrics
mse = mean_squared_error(y_test, predictions)
rmse = np.sqrt(mse)
mae = mean_absolute_error(y_test, predictions)
r2 = r2_score(y_test, predictions)

# Print metrics
print(f"MSE: {mse}")
print(f"RMSE: {rmse}")
print(f"MAE: {mae}")
print(f"R²: {r2}")

# Save metrics
metrics = {
    'regression_metrics': {
        'mse': mse,
        'rmse': rmse,
        'mae': mae,
        'r2': r2
    }
}

# Write metrics to file
with open(os.path.join(output_path, 'evaluation.json'), 'w') as f:
    json.dump(metrics, f)
print("Evaluation completed successfully")