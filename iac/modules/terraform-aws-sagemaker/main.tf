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
                    S3Uri       = { "Get" : "Parameters.InputData" }
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
              Outputs = [
                {
                  OutputName = "evaluation"
                  S3Output = {
                    S3Uri = var.evaluation_output_bucket
                    LocalPath = "/opt/ml/processing/evaluation"
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
            {
              ConditionType = "LessThanOrEqualTo"
              LeftValue = { "Get": "Steps.Evaluate.ProcessingOutputConfig.Outputs['evaluation'].OutputS3Uri" }
              RightValue = { "Get": "Parameters.MSEThreshold" }
            }          
          ]
          IfSteps = [
            {
              Name = "RegisterModel"
              Type = "Model"
              Arguments = {
                ModelName = "mlops-regression-model"
                PrimaryContainer = {
                  Image = data.aws_sagemaker_prebuilt_ecr_image.xgboost.registry_path
                  ModelDataUrl = { "Get": "Steps.TrainModel.ModelArtifacts.S3ModelArtifacts" }
                }
                ExecutionRoleArn = aws_iam_role.example.arn
                ModelPackageGroupName = var.model_package_group_name
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
