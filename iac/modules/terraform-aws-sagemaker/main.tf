resource "aws_iam_role" "example" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_sagemaker_pipeline" "example" {
  pipeline_name         = var.pipeline_name
  pipeline_display_name = var.pipeline_display_name
  role_arn              = aws_iam_role.example.arn

  pipeline_definition = jsonencode(
    {
      "Version" : "2020-12-01",
      "Metadata" : {
        "PipelineName" : "RegressionPipeline",
        "PipelineDescription" : "MLOps pipeline for regression with model evaluation and deployment"
      },
      "PipelineDefinition" : {
        "PipelineExecutionSteps" : [
          {
            "Name" : "PreprocessData",
            "Type" : "Processing",
            "Arguments" : {
              "ProcessingJobName" : "preprocess-job",
              "ProcessingInputs" : [
                {
                  "InputName" : "input-data",
                  "S3Input" : {
                    "S3Uri" : "s3://your-bucket/input-data/",
                    "LocalPath" : "/opt/ml/processing/input",
                    "S3DataType" : "S3Prefix",
                    "S3InputMode" : "File"
                  }
                }
              ],
              "ProcessingOutputConfig" : {
                "Outputs" : [
                  {
                    "OutputName" : "processed-data",
                    "S3Output" : {
                      "S3Uri" : "s3://your-bucket/processed-data/",
                      "LocalPath" : "/opt/ml/processing/output",
                      "S3UploadMode" : "EndOfJob"
                    }
                  }
                ]
              },
              "Code" : "s3://your-bucket/scripts/preprocess.py",
              "ImageUri" : "683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:1.0-1"
            }
          },
          {
            "Name" : "TrainModel",
            "Type" : "Training",
            "Arguments" : {
              "TrainingJobName" : "train-job",
              "AlgorithmSpecification" : {
                "TrainingImage" : "683313688378.dkr.ecr.us-east-1.amazonaws.com/xgboost:1.5-1",
                "TrainingInputMode" : "File"
              },
              "InputDataConfig" : [
                {
                  "ChannelName" : "train",
                  "DataSource" : {
                    "S3DataSource" : {
                      "S3Uri" : "s3://your-bucket/processed-data/train/",
                      "S3DataType" : "S3Prefix",
                      "S3InputMode" : "File"
                    }
                  },
                  "ContentType" : "text/csv"
                }
              ],
              "OutputDataConfig" : {
                "S3OutputPath" : "s3://your-bucket/model-artifacts/"
              },
              "ResourceConfig" : {
                "InstanceType" : "ml.m5.large",
                "InstanceCount" : 1,
                "VolumeSizeInGB" : 10
              },
              "RoleArn" : "arn:aws:iam::your-account-id:role/SageMakerExecutionRole",
              "StoppingCondition" : {
                "MaxRuntimeInSeconds" : 3600
              }
            }
          },
          {
            "Name" : "EvaluateModel",
            "Type" : "Processing",
            "Arguments" : {
              "ProcessingJobName" : "evaluate-job",
              "ProcessingInputs" : [
                {
                  "InputName" : "model",
                  "S3Input" : {
                    "S3Uri" : "s3://your-bucket/model-artifacts/",
                    "LocalPath" : "/opt/ml/processing/model",
                    "S3DataType" : "S3Prefix",
                    "S3InputMode" : "File"
                  }
                },
                {
                  "InputName" : "test-data",
                  "S3Input" : {
                    "S3Uri" : "s3://your-bucket/processed-data/test/",
                    "LocalPath" : "/opt/ml/processing/test",
                    "S3DataType" : "S3Prefix",
                    "S3InputMode" : "File"
                  }
                }
              ],
              "ProcessingOutputConfig" : {
                "Outputs" : [
                  {
                    "OutputName" : "evaluation",
                    "S3Output" : {
                      "S3Uri" : "s3://your-bucket/evaluation/",
                      "LocalPath" : "/opt/ml/processing/evaluation",
                      "S3UploadMode" : "EndOfJob"
                    }
                  }
                ]
              },
              "Code" : "s3://your-bucket/scripts/evaluate.py",
              "ImageUri" : "683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:1.0-1"
            }
          },
          {
            "Name" : "CheckEvaluation",
            "Type" : "Condition",
            "Arguments" : {
              "ConditionType" : "GreaterThanOrEqualTo",
              "LeftValue" : {
                "Get" : "Steps.EvaluateModel.Outputs['evaluation'].Metrics['rmse']"
              },
              "RightValue" : 0.8,
              "IfSteps" : [
                {
                  "Name" : "RegisterModel",
                  "Type" : "Model",
                  "Arguments" : {
                    "ModelName" : "regression-model",
                    "PrimaryContainer" : {
                      "Image" : "683313688378.dkr.ecr.us-east-1.amazonaws.com/xgboost:1.5-1",
                      "ModelDataUrl" : "s3://your-bucket/model-artifacts/model.tar.gz"
                    },
                    "ExecutionRoleArn" : "arn:aws:iam::your-account-id:role/SageMakerExecutionRole"
                  }
                },
                {
                  "Name" : "CreateEndpoint",
                  "Type" : "Endpoint",
                  "Arguments" : {
                    "EndpointConfigName" : "regression-endpoint-config",
                    "EndpointName" : "regression-endpoint",
                    "ProductionVariants" : [
                      {
                        "VariantName" : "AllTraffic",
                        "ModelName" : "regression-model",
                        "InstanceType" : "ml.m5.large",
                        "InitialInstanceCount" : 1
                      }
                    ]
                  }
                }
              ],
              "ElseSteps" : []
            }
          }
        ]
      }
    }

  )
}