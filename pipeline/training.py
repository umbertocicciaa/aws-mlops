import argparse
import pandas as pd
import numpy as np
import os
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

# Parse arguments
parser = argparse.ArgumentParser()
parser.add_argument('--train-test-split-ratio', type=float, default=0.2)
args, _ = parser.parse_known_args()

# Set paths
input_data_path = '/opt/ml/processing/input/data'
output_train_path = '/opt/ml/processing/output/train'
output_validation_path = '/opt/ml/processing/output/validation'
output_test_path = '/opt/ml/processing/output/test'

# Create output directories
os.makedirs(output_train_path, exist_ok=True)
os.makedirs(output_validation_path, exist_ok=True)
os.makedirs(output_test_path, exist_ok=True)

# Read the data
for file in os.listdir(input_data_path):
    if file.endswith('.parquet'):
        data_file = os.path.join(input_data_path, file)
print(f"Reading file: {data_file}")
df = pd.read_parquet(data_file)

# Feature engineering and preprocessing
feature_columns = [col for col in df.columns if col != 'median_house_value']
target_column = 'median_house_value'

# Split the data into features and target
X = df[feature_columns]
y = df[target_column]

# Split into train, validation, and test sets
X_train, X_temp, y_train, y_temp = train_test_split(X, y, test_size=args.train_test_split_ratio*2, random_state=42)
X_val, X_test, y_val, y_test = train_test_split(X_temp, y_temp, test_size=0.5, random_state=42)

# Standardize the features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_val_scaled = scaler.transform(X_val)
X_test_scaled = scaler.transform(X_test)

# Convert to DataFrames with column names
X_train_scaled_df = pd.DataFrame(X_train_scaled, columns=feature_columns)
X_val_scaled_df = pd.DataFrame(X_val_scaled, columns=feature_columns)
X_test_scaled_df = pd.DataFrame(X_test_scaled, columns=feature_columns)

# Add target column back
train_df = X_train_scaled_df.copy()
train_df[target_column] = y_train.values
val_df = X_val_scaled_df.copy()
val_df[target_column] = y_val.values
test_df = X_test_scaled_df.copy()
test_df[target_column] = y_test.values

# Save processed datasets
train_df.to_csv(os.path.join(output_train_path, 'train.csv'), header=False, index=False)
val_df.to_csv(os.path.join(output_validation_path, 'validation.csv'), header=False, index=False)
test_df.to_csv(os.path.join(output_test_path, 'test.csv'), header=False, index=False)
print("Preprocessing completed successfully")