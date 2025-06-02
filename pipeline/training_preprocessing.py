import argparse
import pandas as pd
import numpy as np
import os
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder, OneHotEncoder
from sklearn.compose import ColumnTransformer
import joblib

parser = argparse.ArgumentParser()
parser.add_argument('--train-test-split-ratio', type=float, default=0.2)
args, _ = parser.parse_known_args()

input_data_path = '/opt/ml/processing/input/data'
output_train_path = '/opt/ml/processing/output/train'
output_validation_path = '/opt/ml/processing/output/validation'
output_test_path = '/opt/ml/processing/output/test'

os.makedirs(output_train_path, exist_ok=True)
os.makedirs(output_validation_path, exist_ok=True)
os.makedirs(output_test_path, exist_ok=True)

print(f"Looking for data files in: {input_data_path}")
print(f"Directory contents: {os.listdir(input_data_path) if os.path.exists(input_data_path) else 'Directory does not exist'}")

supported_extensions = ['.parquet', '.csv']
dataframes = []

for file in os.listdir(input_data_path):
    file_path = os.path.join(input_data_path, file)
    if file.endswith('.parquet'):
        print(f"Reading parquet file: {file_path}")
        df_part = pd.read_parquet(file_path)
        dataframes.append(df_part)
    elif file.endswith('.csv'):
        print(f"Reading CSV file: {file_path}")
        df_part = pd.read_csv(file_path)
        dataframes.append(df_part)

if not dataframes:
    raise ValueError(f"No supported data files ({', '.join(supported_extensions)}) found in the input directory")

df = pd.concat(dataframes, ignore_index=True)

print(f"Data shape: {df.shape}")
print(f"Columns: {df.columns.tolist()}")
print(f"First few rows:\n{df.head()}")

target_column = 'median_house_value'

if target_column not in df.columns:
    print(f"Available columns: {df.columns.tolist()}")
    raise ValueError(f"Target column '{target_column}' not found in the dataset")

feature_columns = [col for col in df.columns if col != target_column]
print(f"Feature columns: {feature_columns}")

print(f"Missing values per column:\n{df.isnull().sum()}")
df = df.dropna()
print(f"Data shape after dropping missing values: {df.shape}")

X = df[feature_columns]
y = df[target_column]

print(f"Features shape: {X.shape}")
print(f"Target shape: {y.shape}")

numeric_columns = X.select_dtypes(include=[np.number]).columns.tolist()
categorical_columns = X.select_dtypes(include=['object', 'category']).columns.tolist()

print(f"Numeric columns: {numeric_columns}")
print(f"Categorical columns: {categorical_columns}")

for col in categorical_columns:
    print(f"Unique values in '{col}': {X[col].unique()}")

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

if categorical_columns:
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', StandardScaler(), numeric_columns),
            ('cat', OneHotEncoder(drop='first', sparse=False), categorical_columns)
        ]
    )
    
    X_train_processed = preprocessor.fit_transform(X_train)
    X_val_processed = preprocessor.transform(X_val)
    X_test_processed = preprocessor.transform(X_test)
    
    numeric_feature_names = numeric_columns
    categorical_feature_names = []
    
    if len(categorical_columns) > 0:
        cat_encoder = preprocessor.named_transformers_['cat']
        for i, col in enumerate(categorical_columns):
            categories = cat_encoder.categories_[i][1:]
            for cat in categories:
                categorical_feature_names.append(f"{col}_{cat}")
    
    all_feature_names = numeric_feature_names + categorical_feature_names  
else:
    preprocessor = StandardScaler()
    X_train_processed = preprocessor.fit_transform(X_train)
    X_val_processed = preprocessor.transform(X_val)
    X_test_processed = preprocessor.transform(X_test)
    all_feature_names = numeric_columns

print(f"Final feature names: {all_feature_names}")
print(f"Number of features after preprocessing: {len(all_feature_names)}")

X_train_processed_df = pd.DataFrame(X_train_processed, columns=all_feature_names)
X_val_processed_df = pd.DataFrame(X_val_processed, columns=all_feature_names)
X_test_processed_df = pd.DataFrame(X_test_processed, columns=all_feature_names)

y_train_reset = y_train.reset_index(drop=True)
y_val_reset = y_val.reset_index(drop=True)
y_test_reset = y_test.reset_index(drop=True)

train_df = pd.DataFrame()
train_df[target_column] = y_train_reset.values
train_df = pd.concat([train_df, X_train_processed_df], axis=1)

val_df = pd.DataFrame()
val_df[target_column] = y_val_reset.values
val_df = pd.concat([val_df, X_val_processed_df], axis=1)

test_df = pd.DataFrame()
test_df[target_column] = y_test_reset.values
test_df = pd.concat([test_df, X_test_processed_df], axis=1)

print("Target column is now in position 0 (first column) as required by XGBoost")
print(f"Train columns order: {train_df.columns.tolist()[:5]}...")

train_output_file = os.path.join(output_train_path, 'train.csv')
val_output_file = os.path.join(output_validation_path, 'validation.csv')
test_output_file = os.path.join(output_test_path, 'test.csv')

train_df.to_csv(train_output_file, header=False, index=False, sep=',',encoding='utf-8',)
val_df.to_csv(val_output_file, header=False, index=False, sep=',',encoding='utf-8',)
test_df.to_csv(test_output_file, header=False, index=False, sep=',',encoding='utf-8',)

print(f"Saved train data to: {train_output_file}")
print(f"Saved validation data to: {val_output_file}")
print(f"Saved test data to: {test_output_file}")

feature_names_file = os.path.join(output_train_path, 'feature_names.txt')
with open(feature_names_file, 'w') as f:
    f.write(f"Column 0: {target_column} (TARGET)\n")
    for i, name in enumerate(all_feature_names, 1):
        f.write(f"Column {i}: {name}\n")
print(f"Saved feature names to: {feature_names_file}")

preprocessor_file = os.path.join(output_train_path, 'preprocessor.joblib')
joblib.dump(preprocessor, preprocessor_file)
print(f"Saved preprocessor to: {preprocessor_file}")

print("Preprocessing completed successfully")
print(f"Final train shape: {train_df.shape}")
print(f"Final validation shape: {val_df.shape}")
print(f"Final test shape: {test_df.shape}")

print(f"\nSample of processed train data (first 3 rows, first 5 columns):")
print(train_df.iloc[:3, :5])

print(f"\nTarget column verification:")
print(f"First column name: {train_df.columns[0]}")
print(f"First column values (first 5): {train_df.iloc[:5, 0].tolist()}")
