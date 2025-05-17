import pandas as pd
import joblib
import argparse
import json
from sklearn.metrics import mean_squared_error

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--test', type=str)
    parser.add_argument('--model-dir', type=str)
    parser.add_argument('--output-dir', type=str)
    args = parser.parse_args()

    df = pd.read_parquet(args.test)
    X = df.drop("target", axis=1)
    y = df["target"]

    model = joblib.load(f"{args.model_dir}/model.joblib")
    preds = model.predict(X)

    mse = mean_squared_error(y, preds)

    with open(f"{args.output_dir}/evaluation.json", "w") as f:
        json.dump({"regression_metrics": {"mse": mse}}, f)
