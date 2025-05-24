import argparse
import pandas as pd
import numpy as np
import os
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder, OneHotEncoder
from sklearn.compose import ColumnTransformer

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

print(f"Looking for data files in: {input_data_path}")
print(f"Directory contents: {os.listdir(input_data_path) if os.path.exists(input_data_path) else 'Directory does not exist'}")

# Read the data - check for both parquet and csv files
data_file = None
supported_extensions = ['.parquet', '.csv']

for file in os.listdir(input_data_path):
    for ext in supported_extensions:
        if file.endswith(ext):
            data_file = os.path.join(input_data_path, file)
            file_extension = ext
            break
    if data_file:
        break

if data_file is None:
    raise ValueError(f"No supported data files ({', '.join(supported_extensions)}) found in the input directory")

print(f"Reading file: {data_file}")

# Read data based on file extension
if file_extension == '.parquet':
    df = pd.read_parquet(data_file)
elif file_extension == '.csv':
    df = pd.read_csv(data_file)

print(f"Data shape: {df.shape}")
print(f"Columns: {df.columns.tolist()}")
print(f"First few rows:\n{df.head()}")

# Feature engineering and preprocessing
target_column = 'median_house_value'

# Check if target column exists
if target_column not in df.columns:
    print(f"Available columns: {df.columns.tolist()}")
    raise ValueError(f"Target column '{target_column}' not found in the dataset")

feature_columns = [col for col in df.columns if col != target_column]
print(f"Feature columns: {feature_columns}")

# Handle missing values
print(f"Missing values per column:\n{df.isnull().sum()}")
df = df.dropna()  # Simple approach - drop rows with missing values
print(f"Data shape after dropping missing values: {df.shape}")

# Split the data into features and target
X = df[feature_columns]
y = df[target_column]

print(f"Features shape: {X.shape}")
print(f"Target shape: {y.shape}")

# Identify numeric and categorical columns
numeric_columns = X.select_dtypes(include=[np.number]).columns.tolist()
categorical_columns = X.select_dtypes(include=['object', 'category']).columns.tolist()

print(f"Numeric columns: {numeric_columns}")
print(f"Categorical columns: {categorical_columns}")

# Display unique values for categorical columns
for col in categorical_columns:
    print(f"Unique values in '{col}': {X[col].unique()}")

# Split into train, validation, and test sets
test_size = args.train_test_split_ratio * 2
X_train, X_temp, y_train, y_temp = train_test_split(
    X, y, test_size=test_size, random_state=42, stratify=None
)
X_val, X_test, y_val, y_test = train_test_split(
    X_temp, y_temp, test_size=0.5, random_state=42
)

print(f"Train set shape: {X_train.shape}")
print(f"Validation set shape: {X_val.shape}")
print(f"Test set shape: {X_test.shape}")

# Create preprocessing pipeline
if categorical_columns:
    # Use ColumnTransformer to handle both numeric and categorical columns
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', StandardScaler(), numeric_columns),
            ('cat', OneHotEncoder(drop='first', sparse=False), categorical_columns)
        ]
    )
    
    # Fit and transform the data
    X_train_processed = preprocessor.fit_transform(X_train)
    X_val_processed = preprocessor.transform(X_val)
    X_test_processed = preprocessor.transform(X_test)
    
    # Get feature names after preprocessing
    numeric_feature_names = numeric_columns
    categorical_feature_names = []
    
    # Get categorical feature names from OneHotEncoder
    if len(categorical_columns) > 0:
        cat_encoder = preprocessor.named_transformers_['cat']
        for i, col in enumerate(categorical_columns):
            categories = cat_encoder.categories_[i][1:]  # Skip first category (dropped)
            for cat in categories:
                categorical_feature_names.append(f"{col}_{cat}")
    
    all_feature_names = numeric_feature_names + categorical_feature_names
    
else:
    # Only numeric columns - use StandardScaler directly
    preprocessor = StandardScaler()
    X_train_processed = preprocessor.fit_transform(X_train)
    X_val_processed = preprocessor.transform(X_val)
    X_test_processed = preprocessor.transform(X_test)
    all_feature_names = numeric_columns

print(f"Final feature names: {all_feature_names}")
print(f"Number of features after preprocessing: {len(all_feature_names)}")

# Convert to DataFrames with proper column names
X_train_processed_df = pd.DataFrame(X_train_processed, columns=all_feature_names)
X_val_processed_df = pd.DataFrame(X_val_processed, columns=all_feature_names)
X_test_processed_df = pd.DataFrame(X_test_processed, columns=all_feature_names)

# Reset indices to ensure proper alignment
y_train_reset = y_train.reset_index(drop=True)
y_val_reset = y_val.reset_index(drop=True)
y_test_reset = y_test.reset_index(drop=True)

# Add target column back
train_df = X_train_processed_df.copy()
train_df[target_column] = y_train_reset.values

val_df = X_val_processed_df.copy()
val_df[target_column] = y_val_reset.values

test_df = X_test_processed_df.copy()
test_df[target_column] = y_test_reset.values

# Save processed datasets (without headers for XGBoost compatibility)
train_output_file = os.path.join(output_train_path, 'train.csv')
val_output_file = os.path.join(output_validation_path, 'validation.csv')
test_output_file = os.path.join(output_test_path, 'test.csv')

train_df.to_csv(train_output_file, header=False, index=False)
val_df.to_csv(val_output_file, header=False, index=False)
test_df.to_csv(test_output_file, header=False, index=False)

print(f"Saved train data to: {train_output_file}")
print(f"Saved validation data to: {val_output_file}")
print(f"Saved test data to: {test_output_file}")

# Save feature names for reference
feature_names_file = os.path.join(output_train_path, 'feature_names.txt')
with open(feature_names_file, 'w') as f:
    for name in all_feature_names:
        f.write(f"{name}\n")
print(f"Saved feature names to: {feature_names_file}")

print("Preprocessing completed successfully")
print(f"Final train shape: {train_df.shape}")
print(f"Final validation shape: {val_df.shape}")
print(f"Final test shape: {test_df.shape}")

# Display sample of processed data
print(f"\nSample of processed train data:")
print(train_df.head())