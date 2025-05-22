# S3
resource "random_id" "randomstring" {
  byte_length = 4
}

module "s3" {
  source   = "./modules/terraform-aws-s3-bucket"
  for_each = var.s3_config

  create_bucket = each.value.create_bucket
  bucket        = "${each.value.bucket}-${terraform.workspace}-${random_id.randomstring.hex}"
  force_destroy = each.value.force_destroy
}

module "s3_object" {
  source   = "./modules/terraform-aws-s3-bucket/modules/object"
  for_each = var.s3_object_config

  create        = each.value.create
  bucket        = module.s3["scripts_source_bucket"].s3_bucket_id
  key           = each.value.key
  file_source   = each.value.file_source
  etag          = filemd5("${each.value.file_source}")
  source_hash   = filemd5(each.value.file_source)
  force_destroy = each.value.force_destroy
}

module "s3_object_dataset" {
  source        = "./modules/terraform-aws-s3-bucket/modules/object"
  bucket        = module.s3["data_source_bucket"].s3_bucket_id
  key           = "input/${var.s3_object_dataset_config.key}"
  file_source   = var.s3_object_dataset_config.file_source
  etag          = filemd5("${var.s3_object_dataset_config.file_source}")
  force_destroy = var.s3_object_dataset_config.force_destroy
  source_hash   = filemd5(var.s3_object_dataset_config.file_source)
}

# Etl Preprocessing
module "glue_crawler_trigger" {
  source = "./modules/terraform-aws-glue/modules/glue-trigger"

  name                = "prod-crawler-trigger-elt-preprocessing"
  workflow_name       = module.glue_workflow.name
  trigger_enabled     = true
  start_on_creation   = false
  trigger_description = "Glue Trigger that runs crawler on S3 upload"
  type                = "ON_DEMAND"

  actions = [
    {
      crawler_name = module.glue_crawler.name
    }
  ]

  depends_on = [module.glue_crawler]
}

module "glue_crawler" {
  source = "./modules/terraform-aws-glue/modules/glue-crawler"

  database_name       = module.glue_catalog_database.name
  role                = module.glue_iam_role.arn
  crawler_name        = var.glue_crawler_config.crawler_name
  crawler_description = var.glue_crawler_config.crawler_description
  schedule            = var.glue_crawler_config.schedule

  s3_target = [
    {
      path = "s3://${module.s3["data_source_bucket"].s3_bucket_id}/input/"
    }
  ]

  schema_change_policy = {
    delete_behavior = "LOG"
    update_behavior = null
  }
}

module "glue_catalog_database" {
  source = "./modules/terraform-aws-glue/modules/glue-catalog-database"

  catalog_database_name        = var.glue_catalog_database_config.catalog_database_name
  catalog_database_description = var.glue_catalog_database_config.catalog_database_description
  location_uri                 = "s3://${module.s3["data_source_bucket"].s3_bucket_id}/input/"
  depends_on                   = [module.s3, module.s3_object, module.s3_object_dataset]
}

module "glue_job_trigger" {
  source = "./modules/terraform-aws-glue/modules/glue-trigger"

  name                = "prod-job-trigger-elt-preprocessing"
  workflow_name       = module.glue_workflow.name
  trigger_enabled     = true
  start_on_creation   = false
  trigger_description = "Glue Trigger that runs job after crawler succeeds"
  type                = "CONDITIONAL"

  actions = [
    {
      job_name = module.aws_glue_job.name
      timeout  = 10
    }
  ]

  predicate = {
    conditions = [
      {
        crawler_name = module.glue_crawler.name
        crawl_state  = "SUCCEEDED"
      }
    ]
  }

  depends_on = [module.glue_crawler, module.aws_glue_job]
}

module "aws_glue_job" {
  source = "./modules/terraform-aws-glue/modules/glue-job"

  command = {
    name            = "glueetl"
    script_location = format("s3://%s/pre_processing.py", module.s3["scripts_source_bucket"].s3_bucket_id)
    python_version  = 3
  }
  role_arn          = module.glue_iam_role.arn
  job_name          = var.glue_job_config.job_name
  job_description   = var.glue_job_config.job_description
  glue_version      = var.glue_job_config.glue_version
  timeout           = var.glue_job_config.timeout
  max_retries       = var.glue_job_config.max_retries
  worker_type       = var.glue_job_config.worker_type
  number_of_workers = var.glue_job_config.number_of_workers

  # Pass environment variables to the Glue job script
  default_arguments = merge(
    {
      "--OUTPUT_DIR" = module.s3["pre_processed_data_bucket"].s3_bucket_id
    },
    var.glue_job_config.default_arguments
  )
}

# Glue policy
data "aws_iam_policy_document" "glue_policy_crud" {
  statement {
    sid    = "BaseAccess"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${module.s3["scripts_source_bucket"].s3_bucket_arn}/*",
      "${module.s3["data_source_bucket"].s3_bucket_arn}/*",
      "${module.s3["pre_processed_data_bucket"].s3_bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "glue_policy_list" {
  statement {
    sid    = "FullAccess"
    effect = "Allow"
    resources = [
      module.s3["scripts_source_bucket"].s3_bucket_arn,
      module.s3["data_source_bucket"].s3_bucket_arn,
      module.s3["pre_processed_data_bucket"].s3_bucket_arn
    ]

    actions = [
      "s3:ListBucket"
    ]
  }
}

module "glue_iam_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.21.0"

  name = "glue-iam-role"
  principals = {
    "Service" = ["glue.amazonaws.com"]
  }

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  ]

  policy_documents = [
    data.aws_iam_policy_document.glue_policy_crud.json,
    data.aws_iam_policy_document.glue_policy_list.json
  ]

  policy_document_count = 2
  policy_description    = "Policy for AWS Glue with access to EC2, S3, and Cloudwatch Logs"
  role_description      = "Role for AWS Glue with access to EC2, S3, and Cloudwatch Logs"
}

module "glue_event_bridge" {
  source = "./modules/terraform-aws-eventbridge"

  create      = true
  create_role = true
  create_bus  = false

  rules = {
    gluerule = {
      name        = "trigger-glue-workflow"
      description = "Trigger Glue workflow based on specific events"
      event_pattern = jsonencode({
        "source" : ["aws.s3"],
        "detail-type" : ["Object Created"],
        "detail" : {
          "bucket" : {
            "name" : ["${module.s3["data_source_bucket"].s3_bucket_id}"]
          }
        }
      })
    }
  }
  targets = {
    gluerule = [
      {
        name = "lambda-glue-trigger"
        arn  = module.lambda_function.lambda_function_arn
      }
    ]
  }

  role_name = var.eventbridge_config.role_name

  attach_policy_statements = true
  policy_statements = {
    glue = {
      effect    = "Allow",
      actions   = ["glue:StartTrigger"],
      resources = ["${module.glue_job_trigger.arn}"],
    },
  }
}

# Glue workflow
module "glue_workflow" {
  source = "./modules/terraform-aws-glue/modules/glue-workflow"

  name                 = "glue-workflow-elt-preprocessing"
  workflow_name        = var.glue_workflow_config.workflow_name
  workflow_description = var.glue_workflow_config.workflow_description
  max_concurrent_runs  = var.glue_workflow_config.max_concurrent_runs
}

# lambda
data "archive_file" "lambda_archive" {
  type        = "zip"
  output_path = "../lambda/glue_trigger.zip"

  source_dir = "../lambda/"
}

module "lambda_function" {
  source = "./modules/terraform-aws-lambda"

  function_name = "trigger-glue-workflow-lambda"
  description   = "Lambda function to trigger Glue workflow"
  handler       = "glue_trigger.handler"
  runtime       = "python3.12"
  publish       = true

  create_package          = false
  local_existing_package  = data.archive_file.lambda_archive.output_path
  ignore_source_code_hash = false

  environment_variables = {
    GLUE_TRIGGER_NAME = module.glue_crawler_trigger.name
  }

  attach_policy_statements = true
  policy_statements = {
    glue = {
      effect  = "Allow",
      actions = ["glue:StartTrigger"],
      resources = [
        module.glue_crawler_trigger.arn,
        module.glue_job_trigger.arn
      ]
    }
  }

  depends_on = [module.glue_crawler_trigger]
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = module.glue_event_bridge.eventbridge_rule_arns["gluerule"]
}

# Sagemaker
module "sagemaker" {
  source = "./modules/terraform-aws-sagemaker"

  s3_data_bucket_name = module.s3["data_source_bucket"].s3_bucket_id
  s3_data_key         = module.s3_object["pre_processing_object"].s3_object_id
  sagemaker_bucket    = module.s3["scripts_source_bucket"].s3_bucket_id
}

module "mlops_event_bridge" {
  source = "./modules/terraform-aws-eventbridge"

  create      = true
  create_role = true
  create_bus  = false

  rules = {
    parquet_upload_rule = {
      name        = "parquet-upload-trigger-sagemaker"
      description = "Trigger SageMaker pipeline when parquet files are uploaded"
      event_pattern = jsonencode({
        "source" : ["aws.s3"],
        "detail-type" : ["Object Created"],
        "detail" : {
          "bucket" : {
            "name" : ["${module.s3["pre_processed_data_bucket"].s3_bucket_id}"]
          },
          "object" : {
            "key" : [{ "suffix" : ".parquet" }]
          }
        }
      })
    }
  }

  targets = {
    parquet_upload_rule = [{
      name            = "sagemaker-pipeline-trigger"
      arn             = module.sagemaker.sagemaker_pipeline_arn
      attach_role_arn = true
    }]
  }

  role_name                = var.eventbridge_mlops_config.role_name
  attach_policy_statements = true
  policy_statements = {
    sagemaker = {
      effect    = "Allow",
      actions   = ["sagemaker:StartPipelineExecution"],
      resources = ["${module.sagemaker.sagemaker_pipeline_arn}"],
    },
  }
}

