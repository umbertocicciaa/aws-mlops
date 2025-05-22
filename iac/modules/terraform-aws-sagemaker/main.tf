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

resource "aws_iam_policy" "sagemaker_ecr_policy" {
  name        = "${var.project_name}-sagemaker-ecr-policy"
  description = "Allow SageMaker to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_ecr_policy_attachment" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_ecr_policy.arn
}

# Sagemaker domain
resource "aws_sagemaker_domain" "studio" {
  domain_name = var.domain_name
  auth_mode   = "IAM"
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids

  default_user_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn
  }
}

resource "aws_sagemaker_user_profile" "user" {
  domain_id         = aws_sagemaker_domain.studio.id
  user_profile_name = var.user_profile_name
  user_settings {
    execution_role  = aws_iam_role.sagemaker_execution_role.arn
    security_groups = var.security_group_ids
  }
}

# Sagemaker pipeline
resource "aws_sagemaker_model_package_group" "model_package_group" {
  model_package_group_name        = "${var.project_name}-models"
  model_package_group_description = "Model package group for California Housing regression models"
}

locals {
  sklearn_image_uri = "659782779980.dkr.ecr.eu-west-3.amazonaws.com/sagemaker-scikit-learn:0.23-1-cpu-py3"
  xgboost_image_uri = "659782779980.dkr.ecr.eu-west-3.amazonaws.com/sagemaker-xgboost:1.7-1"
}

resource "aws_sagemaker_pipeline" "mlops_pipeline" {
  pipeline_name         = "${var.project_name}-pipeline"
  pipeline_display_name = "California-Housing-Regression-Pipeline"
  role_arn              = aws_iam_role.sagemaker_execution_role.arn

  pipeline_definition = jsonencode({
    Version = "2020-12-01",
    Parameters = [
      {
        Name         = "ProcessingInstanceType",
        Type         = "String",
        DefaultValue = "${var.instance_type}"
      },
      {
        Name         = "TrainingInstanceType",
        Type         = "String",
        DefaultValue = "${var.instance_type}"
      },
      {
        Name         = "ModelApprovalStatus",
        Type         = "String",
        DefaultValue = "${var.model_approval_status}"
      },
      {
        Name         = "DataS3Uri",
        Type         = "String",
        DefaultValue = "s3://${var.s3_data_bucket_name}/"
      },
      {
        Name         = "RMSEThreshold",
        Type         = "Float",
        DefaultValue = 0.6
      }
    ],
    Steps = [
      {
        Name = "DataPreprocessing",
        Type = "Processing",
        Arguments = {
          AppSpecification = {
            ImageUri            = "${local.sklearn_image_uri}",
            ContainerEntrypoint = ["python3", "/opt/ml/processing/input/code/training.py"]
          },
          ProcessingInputs = [
            {
              InputName  = "code",
              AppManaged = false,
              S3Input = {
                S3Uri                  = "s3://${var.scripts_bucket}/training.py",
                LocalPath              = "/opt/ml/processing/input/code",
                S3DataType             = "S3Prefix",
                S3InputMode            = "File",
                S3DataDistributionType = "FullyReplicated",
                S3CompressionType      = "None"
              }
            },
            {
              InputName  = "data",
              AppManaged = false,
              S3Input = {
                S3Uri = {
                  Get = "Parameters.DataS3Uri"
                },
                LocalPath              = "/opt/ml/processing/input/data",
                S3DataType             = "S3Prefix",
                S3InputMode            = "File",
                S3DataDistributionType = "FullyReplicated",
                S3CompressionType      = "None"
              }
            }
          ],
          ProcessingOutputConfig = {
            Outputs = [
              {
                OutputName = "train",
                AppManaged = false,
                S3Output = {
                  S3Uri        = "s3://${var.s3_data_bucket_name}/output/preprocessing/train",
                  LocalPath    = "/opt/ml/processing/output/train",
                  S3UploadMode = "EndOfJob"
                }
              },
              {
                OutputName = "validation",
                AppManaged = false,
                S3Output = {
                  S3Uri        = "s3://${var.s3_data_bucket_name}/output/preprocessing/validation",
                  LocalPath    = "/opt/ml/processing/output/validation",
                  S3UploadMode = "EndOfJob"
                }
              },
              {
                OutputName = "test",
                AppManaged = false,
                S3Output = {
                  S3Uri        = "s3://${var.s3_data_bucket_name}/output/preprocessing/test",
                  LocalPath    = "/opt/ml/processing/output/test",
                  S3UploadMode = "EndOfJob"
                }
              }
            ]
          },
          ProcessingResources = {
            ClusterConfig = {
              InstanceCount = 1,
              InstanceType = {
                Get = "Parameters.ProcessingInstanceType"
              },
              VolumeSizeInGB = 30
            }
          },
          RoleArn = "${aws_iam_role.sagemaker_execution_role.arn}"
        }
      },
      {
        Name = "ModelTraining",
        Type = "Training",
        Arguments = {
          AlgorithmSpecification = {
            TrainingImage     = local.xgboost_image_uri,
            TrainingInputMode = "File"
          },
          InputDataConfig = [
            {
              ChannelName = "train",
              DataSource = {
                S3DataSource = {
                  S3DataType = "S3Prefix",
                  S3Uri = {
                    Get = "Steps.DataPreprocessing.ProcessingOutputConfig.Outputs[0].S3Output.S3Uri"
                  },
                  S3DataDistributionType = "FullyReplicated"
                }
              },
              ContentType     = "text/csv",
              CompressionType = "None"
            },
            {
              ChannelName = "validation",
              DataSource = {
                S3DataSource = {
                  S3DataType = "S3Prefix",
                  S3Uri = {
                    Get = "Steps.DataPreprocessing.ProcessingOutputConfig.Outputs[1].S3Output.S3Uri"
                  },
                  S3DataDistributionType = "FullyReplicated"
                }
              },
              ContentType     = "text/csv",
              CompressionType = "None"
            }
          ],
          OutputDataConfig = {
            S3OutputPath = "s3://${var.s3_data_bucket_name}/output/model"
          },
          ResourceConfig = {
            InstanceCount = 1,
            InstanceType = {
              Get = "Parameters.TrainingInstanceType"
            },
            VolumeSizeInGB = 30
          },
          StoppingCondition = {
            MaxRuntimeInSeconds = 86400
          },
          HyperParameters = {
            objective        = "reg:squarederror",
            num_round        = "100",
            max_depth        = "6",
            eta              = "0.2",
            gamma            = "4",
            min_child_weight = "6",
            subsample        = "0.7"
          },
          RoleArn = "${aws_iam_role.sagemaker_execution_role.arn}"
        },
        DependsOn = ["DataPreprocessing"]
      },
      {
        Name = "ModelEvaluation",
        Type = "Processing",
        Arguments = {
          AppSpecification = {
            ImageUri            = "${local.sklearn_image_uri}",
            ContainerEntrypoint = ["python3", "/opt/ml/processing/input/code/evaluate.py"]
          },
          ProcessingInputs = [
            {
              InputName  = "code",
              AppManaged = false,
              S3Input = {
                S3Uri                  = "s3://${var.scripts_bucket}/evaluate.py",
                LocalPath              = "/opt/ml/processing/input/code",
                S3DataType             = "S3Prefix",
                S3InputMode            = "File",
                S3DataDistributionType = "FullyReplicated",
                S3CompressionType      = "None"
              }
            },
            {
              InputName  = "test",
              AppManaged = false,
              S3Input = {
                S3Uri = {
                  Get = "Steps.DataPreprocessing.ProcessingOutputConfig.Outputs[2].S3Output.S3Uri"
                },
                LocalPath              = "/opt/ml/processing/input/test",
                S3DataType             = "S3Prefix",
                S3InputMode            = "File",
                S3DataDistributionType = "FullyReplicated",
                S3CompressionType      = "None"
              }
            },
            {
              InputName  = "model",
              AppManaged = false,
              S3Input = {
                S3Uri = {
                  Get = "Steps.ModelTraining.ModelArtifacts.S3ModelArtifacts"
                },
                LocalPath              = "/opt/ml/processing/input/model",
                S3DataType             = "S3Prefix",
                S3InputMode            = "File",
                S3DataDistributionType = "FullyReplicated",
                S3CompressionType      = "None"
              }
            }
          ],
          ProcessingOutputConfig = {
            Outputs = [
              {
                OutputName = "metrics",
                AppManaged = false,
                S3Output = {
                  S3Uri        = "s3://${var.s3_data_bucket_name}/output/metrics",
                  LocalPath    = "/opt/ml/processing/output/metrics",
                  S3UploadMode = "EndOfJob"
                }
              },
              {
                OutputName = "evaluation",
                AppManaged = false,
                S3Output = {
                  S3Uri        = "s3://${var.s3_data_bucket_name}/output/evaluation",
                  LocalPath    = "/opt/ml/processing/output/evaluation",
                  S3UploadMode = "EndOfJob"
                }
              }
            ]
          },
          ProcessingResources = {
            ClusterConfig = {
              InstanceCount = 1,
              InstanceType = {
                Get = "Parameters.ProcessingInstanceType"
              },
              VolumeSizeInGB = 30
            }
          },
          RoleArn = "${aws_iam_role.sagemaker_execution_role.arn}"
        },
        DependsOn = ["ModelTraining"]
      },
      {
        Name = "RegisterModel",
        Type = "RegisterModel",
        Arguments = {
          ModelPackageGroupName = "${aws_sagemaker_model_package_group.model_package_group.model_package_group_name}",
          ModelApprovalStatus = {
            Get = "Parameters.ModelApprovalStatus"
          },
          InferenceSpecification = {
            Containers = [
              {
                Image = local.xgboost_image_uri
              }
            ],
            SupportedContentTypes      = ["text/csv"],
            SupportedResponseMIMETypes = ["text/csv"]
          },
          ModelMetrics = {
            ModelQuality = {
              Statistics = {
                ContentType = "application/json",
                S3Uri = {
                  Get = "Steps.ModelEvaluation.ProcessingOutputConfig.Outputs[1].S3Output.S3Uri"
                }
              }
            }
          },
          ModelPackageDescription = "California Housing regression model",
        },
        DependsOn = ["ModelEvaluation"]
      },
      {
        Name      = "CreateModelStep",
        Type      = "Model",
        DependsOn = ["RegisterModel"],
        Arguments = {
          PrimaryContainer = {
            Image = "683313688378.dkr.ecr.us-west-2.amazonaws.com/sagemaker-xgboost:1.5-1",
            ModelDataUrl = {
              Get = "Steps.ModelTraining.ModelArtifacts.S3ModelArtifacts"
            }
          },
          ExecutionRoleArn = "${aws_iam_role.sagemaker_execution_role.arn}"
        }
      },
      {
        Name      = "DeploymentStep",
        Type      = "EndpointConfig",
        DependsOn = ["CreateModelStep"],
        Arguments = {
          EndpointConfigName = "california-housing-endpoint-config",
          ProductionVariants = [
            {
              ModelName = {
                Get = "Steps.CreateModelStep.ModelName"
              },
              VariantName          = "AllTraffic",
              InitialInstanceCount = 1,
              InstanceType         = "ml.m5.large"
              ManagedInstanceScaling = {
                MinInstanceCount = 1,
                MaxInstanceCount = 2
              }
            }
          ]
        }
      },
      {
        Name      = "EndpointDeploymentStep",
        Type      = "Endpoint",
        DependsOn = ["DeploymentStep"],
        Arguments = {
          EndpointName = "california-housing-endpoint",
          EndpointConfigName = {
            Get = "Steps.DeploymentStep.EndpointConfigName"
          }
        }
      }
    ]
  })
}