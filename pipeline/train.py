import pandas as pd
import xgboost as xgb
import argparse
import joblib
import os

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--train', type=str)
    parser.add_argument('--model-dir', type=str)
    args = parser.parse_args()

    df = pd.read_parquet(args.train)
    X = df.drop("target", axis=1)
    y = df["target"]

    model = xgb.XGBRegressor()
    model.fit(X, y)

    joblib.dump(model, os.path.join(args.model_dir, "model.joblib"))
