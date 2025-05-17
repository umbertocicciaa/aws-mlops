# Datas
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# IAM Role for SageMaker
resource "aws_iam_role" "sagemaker_execution_role" {
  name = "${var.project_name}-sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Sagemaker
resource "aws_sagemaker_pipeline" "mlops_pipeline" {
  pipeline_name         = "${var.project_name}-pipeline"
  pipeline_display_name = "California Housing Regression Pipeline"
  role_arn              = aws_iam_role.sagemaker_execution_role.arn

  pipeline_definition = jsonencode({
    "Version" : "2020-12-01",
    "Parameters" : [
      {
        "Name" : "ProcessingInstanceType",
        "Type" : "String",
        "DefaultValue" : "${var.instance_type}"
      },
      {
        "Name" : "TrainingInstanceType",
        "Type" : "String",
        "DefaultValue" : "${var.instance_type}"
      },
      {
        "Name" : "ModelApprovalStatus",
        "Type" : "String",
        "DefaultValue" : "${var.model_approval_status}"
      },
      {
        "Name" : "DataS3Uri",
        "Type" : "String",
        "DefaultValue" : "s3://${var.s3_data_bucket_name}/${var.s3_data_key}"
      }
    ],
    "Steps" : [
      {
        "Name" : "DataPreprocessing",
        "Type" : "Processing",
        "Arguments" : {
          "ProcessingInputs" : [
            {
              "InputName" : "code",
              "S3Input" : {
                "S3Uri" : "s3://${aws_s3_bucket.var.sagemaker_bucket.bucket}/training.py",
                "LocalPath" : "/opt/ml/processing/input/code",
                "S3DataType" : "S3Prefix",
                "S3InputMode" : "File",
                "S3DataDistributionType" : "FullyReplicated",
                "S3CompressionType" : "None"
              }
            },
            {
              "InputName" : "data",
              "S3Input" : {
                "S3Uri" : { "Get" : "Parameters.DataS3Uri" },
                "LocalPath" : "/opt/ml/processing/input/data",
                "S3DataType" : "S3Prefix",
                "S3InputMode" : "File",
                "S3DataDistributionType" : "FullyReplicated",
                "S3CompressionType" : "None"
              }
            }
          ],
          "ProcessingOutputs" : [
            {
              "OutputName" : "train",
              "S3Output" : {
                "S3Uri" : "s3://${aws_s3_bucket.var.sagemaker_bucket.bucket}/output/preprocessing/train",
                "LocalPath" : "/opt/ml/processing/output/train",
                "S3UploadMode" : "EndOfJob"
              }
            },
            {
              "OutputName" : "validation",
              "S3Output" : {
                "S3Uri" : "s3://${aws_s3_bucket.var.sagemaker_bucket.bucket}/output/preprocessing/validation",
                "LocalPath" : "/opt/ml/processing/output/validation",
                "S3UploadMode" : "EndOfJob"
              }
            },
            {
              "OutputName" : "test",
              "S3Output" : {
                "S3Uri" : "s3://${aws_s3_bucket.var.sagemaker_bucket.bucket}/output/preprocessing/test",
                "LocalPath" : "/opt/ml/processing/output/test",
                "S3UploadMode" : "EndOfJob"
              }
            }
          ],
          "AppSpecification" : {
            "ImageUri" : { "Fn::Join" : ["", ["${data.aws_caller_identity.current.account_id}", ".dkr.ecr.", "${data.aws_region.current.name}", ".amazonaws.com/sagemaker-scikit-learn:1.0-1"]] },
            "ContainerEntrypoint" : ["python3", "/opt/ml/processing/input/training.py"]
          },
          "ProcessingResources" : {
            "ClusterConfig" : {
              "InstanceCount" : 1,
              "InstanceType" : { "Get" : "Parameters.ProcessingInstanceType" },
              "VolumeSizeInGB" : 30
            }
          },
          "RoleArn" : "${aws_iam_role.sagemaker_execution_role.arn}"
        }
      },
      {
        "Name" : "ModelTraining",
        "Type" : "Training",
        "Arguments" : {
          "AlgorithmSpecification" : {
            "TrainingImage" : "683313688378.dkr.ecr.us-west-2.amazonaws.com/sagemaker-xgboost:1.5-1",
            "TrainingInputMode" : "File"
          },
          "InputDataConfig" : [
            {
              "ChannelName" : "train",
              "DataSource" : {
                "S3DataSource" : {
                  "S3DataType" : "S3Prefix",
                  "S3Uri" : { "Get" : "Steps.DataPreprocessing.ProcessingOutputConfig.Outputs['train'].S3Output.S3Uri" },
                  "S3DataDistributionType" : "FullyReplicated"
                }
              },
              "ContentType" : "text/csv",
              "CompressionType" : "None"
            },
            {
              "ChannelName" : "validation",
              "DataSource" : {
                "S3DataSource" : {
                  "S3DataType" : "S3Prefix",
                  "S3Uri" : { "Get" : "Steps.DataPreprocessing.ProcessingOutputConfig.Outputs['validation'].S3Output.S3Uri" },
                  "S3DataDistributionType" : "FullyReplicated"
                }
              },
              "ContentType" : "text/csv",
              "CompressionType" : "None"
            }
          ],
          "OutputDataConfig" : {
            "S3OutputPath" : "s3://${aws_s3_bucket.var.sagemaker_bucket.bucket}/output/model"
          },
          "ResourceConfig" : {
            "InstanceCount" : 1,
            "InstanceType" : { "Get" : "Parameters.TrainingInstanceType" },
            "VolumeSizeInGB" : 30
          },
          "StoppingCondition" : {
            "MaxRuntimeInSeconds" : 86400
          },
          "HyperParameters" : {
            "objective" : "reg:squarederror",
            "num_round" : "100",
            "max_depth" : "6",
            "eta" : "0.2",
            "gamma" : "4",
            "min_child_weight" : "6",
            "subsample" : "0.7"
          },
          "RoleArn" : "${aws_iam_role.sagemaker_execution_role.arn}"
        },
        "DependsOn" : ["DataPreprocessing"]
      },
      {
        "Name" : "ModelEvaluation",
        "Type" : "Processing",
        "Arguments" : {
          "ProcessingInputs" : [
            {
              "InputName" : "code",
              "S3Input" : {
                "S3Uri" : "s3://${aws_s3_bucket.var.sagemaker_bucket.bucket}/evaluate.py",
                "LocalPath" : "/opt/ml/processing/input/code",
                "S3DataType" : "S3Prefix",
                "S3InputMode" : "File",
                "S3DataDistributionType" : "FullyReplicated",
                "S3CompressionType" : "None"
              }
            },
            {
              "InputName" : "test",
              "S3Input" : {
                "S3Uri" : { "Get" : "Steps.DataPreprocessing.ProcessingOutputConfig.Outputs['test'].S3Output.S3Uri" },
                "LocalPath" : "/opt/ml/processing/input/test",
                "S3DataType" : "S3Prefix",
                "S3InputMode" : "File",
                "S3DataDistributionType" : "FullyReplicated",
                "S3CompressionType" : "None"
              }
            },
            {
              "InputName" : "model",
              "S3Input" : {
                "S3Uri" : { "Get" : "Steps.ModelTraining.ModelArtifacts.S3ModelArtifacts" },
                "LocalPath" : "/opt/ml/processing/input/model",
                "S3DataType" : "S3Prefix",
                "S3InputMode" : "File",
                "S3DataDistributionType" : "FullyReplicated",
                "S3CompressionType" : "None"
              }
            }
          ],
          "ProcessingOutputs" : [
            {
              "OutputName" : "evaluation",
              "S3Output" : {
                "S3Uri" : "s3://${aws_s3_bucket.var.sagemaker_bucket.bucket}/output/evaluation",
                "LocalPath" : "/opt/ml/processing/output/evaluation",
                "S3UploadMode" : "EndOfJob"
              }
            }
          ],
          "AppSpecification" : {
            "ImageUri" : { "Fn::Join" : ["", ["${data.aws_caller_identity.current.account_id}", ".dkr.ecr.", "${data.aws_region.current.name}", ".amazonaws.com/sagemaker-scikit-learn:1.0-1"]] },
            "ContainerEntrypoint" : ["python3", "/opt/ml/processing/input/evaluate.py"]
          },
          "ProcessingResources" : {
            "ClusterConfig" : {
              "InstanceCount" : 1,
              "InstanceType" : { "Get" : "Parameters.ProcessingInstanceType" },
              "VolumeSizeInGB" : 30
            }
          },
          "RoleArn" : "${aws_iam_role.sagemaker_execution_role.arn}"
        },
        "DependsOn" : ["ModelTraining"]
      },
      {
        "Name" : "ModelEvaluationCheck",
        "Type" : "Condition",
        "Arguments" : {
          "Conditions" : [
            {
              "Type" : "LessThanOrEqualTo",
              "LeftValue" : {
                "Get" : "Steps.ModelEvaluation.ProcessingOutputConfig.Outputs['evaluation'].S3Output.S3Uri"
              },
              "RightValue" : "0.6"
            }
          ]
        },
        "DependsOn" : ["ModelEvaluation"]
      },
      {
        "Name" : "RegisterModel",
        "Type" : "RegisterModel",
        "Arguments" : {
          "ModelPackageGroupName" : "${aws_sagemaker_model_package_group.model_package_group.model_package_group_name}",
          "ModelApprovalStatus" : { "Get" : "Parameters.ModelApprovalStatus" },
          "InferenceSpecification" : {
            "Containers" : [
              {
                "Image" : "683313688378.dkr.ecr.us-west-2.amazonaws.com/sagemaker-xgboost:1.5-1"
              }
            ],
            "SupportedContentTypes" : ["text/csv"],
            "SupportedResponseMIMETypes" : ["text/csv"]
          },
          "ModelMetrics" : {
            "ModelQuality" : {
              "Statistics" : {
                "ContentType" : "application/json",
                "S3Uri" : { "Get" : "Steps.ModelEvaluation.ProcessingOutputConfig.Outputs['evaluation'].S3Output.S3Uri" }
              }
            }
          },
          "ModelPackageDescription" : "California Housing regression model",
          "SourceModelPackageName" : { "Get" : "Steps.ModelTraining.ModelArtifacts.S3ModelArtifacts" }
        },
        "DependsOn" : ["ModelEvaluationCheck"]
      }
    ]
  })
}

resource "aws_sagemaker_model" "model" {
  name               = "${var.project_name}-model"
  execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

  primary_container {
    image          = "683313688378.dkr.ecr.us-west-2.amazonaws.com/sagemaker-xgboost:1.5-1"
    model_data_url = "s3://${aws_s3_bucket.var.sagemaker_bucket.bucket}/output/model/model.tar.gz"
  }

  # This resource depends on the pipeline execution which creates the model
  # In a real scenario, you would have a mechanism to trigger this after model creation
  depends_on = [aws_sagemaker_pipeline.mlops_pipeline]
}

resource "aws_sagemaker_model_package_group" "model_package_group" {
  model_package_group_name        = "${var.project_name}-models"
  model_package_group_description = "Model package group for California Housing regression models"
}

resource "aws_sagemaker_endpoint_config" "endpoint_config" {
  name = "${var.project_name}-endpoint-config"

  production_variants {
    variant_name           = "default"
    model_name             = aws_sagemaker_model.model.name
    instance_type          = "ml.t2.medium"
    initial_instance_count = 1
  }

  # This resource depends on the pipeline execution which registers the model
  # In a real scenario, you would have a mechanism to trigger this after model registration
  depends_on = [aws_sagemaker_pipeline.mlops_pipeline]
}

resource "aws_sagemaker_endpoint" "endpoint" {
  name                 = "${var.project_name}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_config.endpoint_config.name
}
