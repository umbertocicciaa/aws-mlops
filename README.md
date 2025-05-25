[![Build and Deploy Frontend Docker Image](https://github.com/umbertocicciaa/aws-mlops/actions/workflows/frontend.yaml/badge.svg)](https://github.com/umbertocicciaa/aws-mlops/actions/workflows/frontend.yaml)

[![Deploy Infrastructure with Terraform](https://github.com/umbertocicciaa/aws-mlops/actions/workflows/iac.yaml/badge.svg)](https://github.com/umbertocicciaa/aws-mlops/actions/workflows/iac.yaml)

# AWS MLOps with Glue and SageMaker

## Overview

This project implements an end-to-end MLOps pipeline on AWS for the California Housing dataset, focusing on linear regression prediction. The architecture leverages AWS Glue for ETL preprocessing, Lambda and EventBridge for orchestration, SageMaker for model training and deployment, and a Streamlit frontend for user interaction.

---

## Architecture

1. **ETL Pipeline with AWS Glue**
   - Raw data is uploaded to an S3 data bucket.
   - An [EventBridge](iac/modules/terraform-aws-eventbridge/README.md) rule detects new uploads and triggers a [Lambda function](iac/modules/terraform-aws-lambda/README.md).
   - The Lambda function starts an [AWS Glue](iac/modules/terraform-aws-glue/README.md) workflow to preprocess the California Housing dataset (see [pre_processing.py](data-preprocessing/pre_processing.py)).
   - Cleaned data is written to a final preprocessed S3 bucket.

2. **Triggering SageMaker MLOps Pipeline**
   - Upload of the preprocessed file to the S3 bucket triggers another EventBridge rule.
   - This rule starts the [SageMaker MLOps pipeline](iac/modules/terraform-aws-sagemaker/README.md), which:
     - Runs further data processing ([training_preprocessing.py](pipeline/training_preprocessing.py))
     - Trains a linear regression model using XGBoost
     - Registers and deploys the model as an endpoint

3. **Model Serving API**
   - After training, the model is deployed as a SageMaker endpoint.
   - An API is exposed for making predictions using this endpoint.

4. **Frontend**
   - The [frontend](frontend/README.md) is built with Streamlit, allowing users to interact visually with the model and make predictions.

---

## Getting Started

1. **Infrastructure Deployment**
   - All AWS resources are provisioned using Terraform modules in the `iac/` directory.
   - Configure your AWS credentials and run `terraform init && terraform apply` in the `iac/` folder.

2. **Data Upload**
   - Upload raw California Housing data to the designated S3 data bucket.
   - This triggers the ETL pipeline automatically.

3. **Model Training and Deployment**
   - Once preprocessing is complete, the pipeline triggers SageMaker for training and deployment.
   - The trained model is registered and deployed as an endpoint.

4. **API and Frontend**
   - Use the provided API to make predictions.
   - Launch the Streamlit frontend for visual interaction.

---

## References

- [AWS Glue Documentation](https://docs.aws.amazon.com/glue/)
- [AWS SageMaker Documentation](https://docs.aws.amazon.com/sagemaker/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---
