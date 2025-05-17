resource "aws_sagemaker_pipeline" "mlops_regression" {
  pipeline_name         = var.pipeline_name
  pipeline_display_name = var.pipeline_display_name
  role_arn              = aws_iam_role.example.arn

  pipeline_definition = jsonencode({
    Version = "2020-12-01"
    Parameters = [
      {
        Name         = "InputData"
        Type         = "String"
        DefaultValue = var.input_data
      },
      {
        Name         = "MSEThreshold"
        Type         = "Float"
        DefaultValue = var.mse_threshold
      }
    ]
    Steps = [
      {
        Name = "Preprocess"
        Type = "Processing"
        Arguments = {
          ProcessingJobDefinition = {
            AppSpecification = {
              ImageUri            = data.aws_sagemaker_prebuilt_ecr_image.sklearn.registry_path
              ContainerEntrypoint = ["python3"]
            }
            ProcessingInputs = [
              {
                InputName = "input-1"
                S3Input = {
                  S3Uri       = { "Get" : "Parameters.InputData" }
                  LocalPath   = "/opt/ml/processing/input"
                  S3DataType  = "S3Prefix"
                  S3InputMode = "File"
                }
              }
            ]
            ProcessingOutputConfig = {
              Outputs = [
                {
                  OutputName = "output-1"
                  S3Output = {
                    S3Uri        = "s3://your-bucket/processing/output/"
                    LocalPath    = "/opt/ml/processing/output"
                    S3UploadMode = "EndOfJob"
                  }
                }
              ]
            }
            ResourceConfig = {
              InstanceType   = "ml.m5.large"
              InstanceCount  = 1
              VolumeSizeInGB = 30
            }
            RoleArn     = aws_iam_role.example.arn
            Code        = var.preprocess_script_bucket
            Environment = {}
          }
        }
      },
      {
        Name = "TrainModel"
        Type = "Training"
        Arguments = {
          TrainingJobDefinition = {
            AlgorithmSpecification = {
              TrainingImage     = data.aws_sagemaker_prebuilt_ecr_image.xgboost.registry_path
              TrainingInputMode = "File"
            }
            InputDataConfig = [
              {
                ChannelName = "train"
                DataSource = {
                  S3DataSource = {
                    S3Uri       = { "Get" : "Steps.Preprocess.ProcessingOutputConfig.Outputs[0].S3Output.S3Uri" }
                    S3DataType  = "S3Prefix"
                    S3InputMode = "File"
                  }
                }
              }
            ]
            OutputDataConfig = {
              S3OutputPath = var.model_artifact_bucket
            }
            ResourceConfig = {
              InstanceType   = "ml.m5.large"
              InstanceCount  = 1
              VolumeSizeInGB = 30
            }
            RoleArn = aws_iam_role.example.arn
            HyperParameters = {
              "objective" = "reg:squarederror"
            }
            StoppingCondition = {
              MaxRuntimeInSeconds = 3600
            }
            EntryPoint = var.mode_training_script_bucket
          }
        }
      },
      {
        Name = "Evaluate"
        Type = "Processing"
        Arguments = {
          ProcessingJobDefinition = {
            AppSpecification = {
              ImageUri            = data.aws_sagemaker_prebuilt_ecr_image.sklearn.registry_path
              ContainerEntrypoint = ["python3"]
            }
            ProcessingInputs = [
              {
                InputName = "model"
                S3Input = {
                  S3Uri       = { "Get" : "Steps.TrainModel.ModelArtifacts.S3ModelArtifacts" }
                  LocalPath   = "/opt/ml/processing/model"
                  S3DataType  = "S3Prefix"
                  S3InputMode = "File"
                }
              }
            ]
            ProcessingOutputConfig = {
              Outputs = []
            }
            ResourceConfig = {
              InstanceType   = "ml.m5.large"
              InstanceCount  = 1
              VolumeSizeInGB = 30
            }
            RoleArn     = aws_iam_role.example.arn
            Code        = var.model_evaluate_script_bucket
            Environment = {}
          }
        }
      },
      {
        Name = "CheckAccuracy"
        Type = "Condition"
        Arguments = {
          Conditions = [
            # Add your condition logic here, e.g., compare evaluation metric to threshold
          ]
          IfSteps = [
            {
              Name = "RegisterModel"
              Type = "Model"
              Arguments = {
                # Model registration details here
              }
            }
          ]
          ElseSteps = []
        }
      }
    ]
  })
}

data "aws_sagemaker_prebuilt_ecr_image" "sklearn" {
  repository_name = "sagemaker-scikit-learn"
}

data "aws_sagemaker_prebuilt_ecr_image" "xgboost" {
  repository_name = "sagemaker-xgboost"
}

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
