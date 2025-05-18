# S3
resource "random_id" "randomstring" {
  byte_length = 4
}

module "s3" {
  source   = "./modules/terraform-aws-s3-bucket"
  for_each = var.s3_config

  create_bucket                                   = each.value.create_bucket
  attach_elb_log_delivery_policy                  = each.value.attach_elb_log_delivery_policy
  attach_lb_log_delivery_policy                   = each.value.attach_lb_log_delivery_policy
  attach_access_log_delivery_policy               = each.value.attach_access_log_delivery_policy
  attach_deny_insecure_transport_policy           = each.value.attach_deny_insecure_transport_policy
  attach_require_latest_tls_policy                = each.value.attach_require_latest_tls_policy
  attach_policy                                   = each.value.attach_policy
  attach_public_policy                            = each.value.attach_public_policy
  attach_inventory_destination_policy             = each.value.attach_inventory_destination_policy
  attach_analytics_destination_policy             = each.value.attach_analytics_destination_policy
  attach_deny_incorrect_encryption_headers        = each.value.attach_deny_incorrect_encryption_headers
  attach_deny_incorrect_kms_key_sse               = each.value.attach_deny_incorrect_kms_key_sse
  allowed_kms_key_arn                             = each.value.allowed_kms_key_arn
  attach_deny_unencrypted_object_uploads          = each.value.attach_deny_unencrypted_object_uploads
  attach_deny_ssec_encrypted_object_uploads       = each.value.attach_deny_ssec_encrypted_object_uploads
  bucket                                          = "${each.value.bucket}-${terraform.workspace}-${random_id.randomstring.hex}"
  bucket_prefix                                   = each.value.bucket_prefix
  acl                                             = each.value.acl
  policy                                          = each.value.policy
  tags                                            = each.value.tags
  force_destroy                                   = each.value.force_destroy
  acceleration_status                             = each.value.acceleration_status
  request_payer                                   = each.value.request_payer
  website                                         = each.value.website
  cors_rule                                       = each.value.cors_rule
  versioning                                      = each.value.versioning
  logging                                         = each.value.logging
  access_log_delivery_policy_source_buckets       = each.value.access_log_delivery_policy_source_buckets
  access_log_delivery_policy_source_accounts      = each.value.access_log_delivery_policy_source_accounts
  access_log_delivery_policy_source_organizations = each.value.access_log_delivery_policy_source_organizations
  lb_log_delivery_policy_source_organizations     = each.value.lb_log_delivery_policy_source_organizations
  grant                                           = each.value.grant
  owner                                           = each.value.owner
  expected_bucket_owner                           = each.value.expected_bucket_owner
  transition_default_minimum_object_size          = each.value.transition_default_minimum_object_size
  lifecycle_rule                                  = each.value.lifecycle_rule
  replication_configuration                       = each.value.replication_configuration
  server_side_encryption_configuration            = each.value.server_side_encryption_configuration
  intelligent_tiering                             = each.value.intelligent_tiering
  object_lock_configuration                       = each.value.object_lock_configuration
  metric_configuration                            = each.value.metric_configuration
  inventory_configuration                         = each.value.inventory_configuration
  inventory_source_account_id                     = each.value.inventory_source_account_id
  inventory_source_bucket_arn                     = each.value.inventory_source_bucket_arn
  inventory_self_source_destination               = each.value.inventory_self_source_destination
  analytics_configuration                         = each.value.analytics_configuration
  analytics_source_account_id                     = each.value.analytics_source_account_id
  analytics_source_bucket_arn                     = each.value.analytics_source_bucket_arn
  analytics_self_source_destination               = each.value.analytics_self_source_destination
  object_lock_enabled                             = each.value.object_lock_enabled
  block_public_acls                               = each.value.block_public_acls
  block_public_policy                             = each.value.block_public_policy
  ignore_public_acls                              = each.value.ignore_public_acls
  restrict_public_buckets                         = each.value.restrict_public_buckets
  control_object_ownership                        = each.value.control_object_ownership
  object_ownership                                = each.value.object_ownership

  is_directory_bucket  = each.value.is_directory_bucket
  data_redundancy      = each.value.data_redundancy
  type                 = each.value.type
  availability_zone_id = each.value.availability_zone_id
  location_type        = each.value.location_type
}

module "s3_object" {
  source   = "./modules/terraform-aws-s3-bucket/modules/object"
  for_each = var.s3_object_config

  create      = each.value.create
  bucket      = module.s3["scripts_source_bucket"].s3_bucket_id
  key         = each.value.key
  file_source = each.value.file_source
  # content                       = each.value.content
  # content_base64                = each.value.content_base64
  # acl                           = each.value.acl
  # cache_control                 = each.value.cache_control
  # content_disposition           = each.value.content_disposition
  # content_encoding              = each.value.content_encoding
  # content_language              = each.value.content_language
  # content_type                  = each.value.content_type
  # website_redirect              = each.value.website_redirect
  # storage_class                 = each.value.storage_class
  etag = filemd5("${each.value.file_source}")
  # server_side_encryption        = each.value.server_side_encryption
  # kms_key_id                    = each.value.kms_key_id
  # bucket_key_enabled            = each.value.bucket_key_enabled
  # metadata                      = each.value.metadata
  # tags                          = each.value.tags
  force_destroy = each.value.force_destroy
  # object_lock_legal_hold_status = each.value.object_lock_legal_hold_status
  # object_lock_mode              = each.value.object_lock_mode
  # object_lock_retain_until_date = each.value.object_lock_retain_until_date
  # source_hash                   = each.value.source_hash
  # override_default_tags         = each.value.override_default_tags
}

# Etl Preprocessing
module "glue_catalog_database" {
  source = "./modules/terraform-aws-glue/modules/glue-catalog-database"

  catalog_database_name        = var.glue_catalog_database_config.catalog_database_name
  catalog_database_description = var.glue_catalog_database_config.catalog_database_description
  #catalog_id                      = var.glue_catalog_database_config.catalog_id
  #create_table_default_permission = var.glue_catalog_database_config.create_table_default_permission
  location_uri = "s3://${module.s3["scripts_source_bucket"].s3_bucket_id}/${module.s3_object["pre_processing_object"].s3_object_id}"
  #parameters                      = var.glue_catalog_database_config.parameters
  #target_database                 = var.glue_catalog_database_config.target_database
  depends_on = [module.s3, module.s3_object]
}

module "glue_catalog_table" {
  source = "./modules/terraform-aws-glue/modules/glue-catalog-table"

  catalog_table_name        = var.glue_catalog_table_config.catalog_table_name
  catalog_table_description = var.glue_catalog_table_config.catalog_table_description
  database_name             = module.glue_catalog_database.name
  # catalog_id                = var.glue_catalog_table_config.catalog_id
  # owner                     = var.glue_catalog_table_config.owner
  # parameters                = var.glue_catalog_table_config.parameters
  # partition_index           = var.glue_catalog_table_config.partition_index
  # partition_keys            = var.glue_catalog_table_config.partition_keys
  # retention                 = var.glue_catalog_table_config.retention
  # table_type                = var.glue_catalog_table_config.table_type
  # target_table              = var.glue_catalog_table_config.target_table
  # view_expanded_text        = var.glue_catalog_table_config.view_expanded_text
  # view_original_text        = var.glue_catalog_table_config.view_original_text
  storage_descriptor = {
    location = "s3://${module.s3["scripts_source_bucket"].s3_bucket_id}/${module.s3_object["pre_processing_object"].s3_object_id}"
  }
  depends_on = [module.s3, module.s3_object]
}

module "glue_crawler" {
  source = "./modules/terraform-aws-glue/modules/glue-crawler"

  database_name       = module.glue_catalog_database.name
  role                = module.glue_iam_role.arn
  crawler_name        = var.glue_crawler_config.crawler_name
  crawler_description = var.glue_crawler_config.crawler_description
  schedule            = var.glue_crawler_config.schedule
  # classifiers            = var.glue_crawler_config.classifiers
  # configuration          = var.glue_crawler_config.configuration
  # jdbc_target            = var.glue_crawler_config.jdbc_target
  # dynamodb_target        = var.glue_crawler_config.dynamodb_target
  # s3_target              = var.glue_crawler_config.s3_target
  # mongodb_target         = var.glue_crawler_config.mongodb_target
  catalog_target = [
    {
      database_name = module.glue_catalog_database.name
      tables        = [module.glue_catalog_table.name]
    }
  ]
  # delta_target           = var.glue_crawler_config.delta_target
  # table_prefix           = var.glue_crawler_config.table_prefix
  # security_configuration = var.glue_crawler_config.security_configuration
  schema_change_policy = {
    delete_behavior = "LOG"
    update_behavior = null
  }
  # lineage_configuration  = var.glue_crawler_config.lineage_configuration
  # recrawl_policy         = var.glue_crawler_config.recrawl_policy
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

  policy_document_count = 0
  policy_description    = "Policy for AWS Glue with access to EC2, S3, and Cloudwatch Logs"
  role_description      = "Role for AWS Glue with access to EC2, S3, and Cloudwatch Logs"
}

module "glue_workflow" {
  source = "./modules/terraform-aws-glue/modules/glue-workflow"

  name                 = "glue-workflow-elt-preprocessing"
  workflow_name        = var.glue_workflow_config.workflow_name
  workflow_description = var.glue_workflow_config.workflow_description
  #default_run_properties = var.glue_workflow_config.default_run_properties
  max_concurrent_runs = var.glue_workflow_config.max_concurrent_runs
}

module "aws_glue_job" {
  source = "./modules/terraform-aws-glue/modules/glue-job"

  command = {
    name            = "glueetl"
    script_location = format("s3://%s/pre_processing.py", module.s3["scripts_source_bucket"].s3_bucket_id)
    python_version  = 3
  }
  role_arn        = module.glue_iam_role.arn
  job_name        = var.glue_job_config.job_name
  job_description = var.glue_job_config.job_description
  # connections               = var.glue_job_config.connections
  glue_version = var.glue_job_config.glue_version
  # default_arguments         = var.glue_job_config.default_arguments
  # non_overridable_arguments = var.glue_job_config.non_overridable_arguments
  # security_configuration    = var.glue_job_config.security_configuration
  timeout = var.glue_job_config.timeout
  #max_capacity              = var.glue_job_config.max_capacity
  max_retries       = var.glue_job_config.max_retries
  worker_type       = var.glue_job_config.worker_type
  number_of_workers = var.glue_job_config.number_of_workers
  #execution_property        = var.glue_job_config.execution_property
  #notification_property     = var.glue_job_config.notification_property
}

module "glue_trigger" {
  source = "./modules/terraform-aws-glue/modules/glue-trigger"

  name                = "prod-trigger-elt-preprocessing"
  workflow_name       = module.glue_workflow.name
  trigger_enabled     = true
  start_on_creation   = false
  trigger_description = "Glue Trigger that triggers a Glue Job on a schedule"
  type                = "EVENT"

  actions = [
    {
      job_name = module.aws_glue_job.name
      timeout  = 10
    }
  ]

}

# eventbridge configuration
module "glue_event_bridge" {
  source = "./modules/terraform-aws-eventbridge"

  create      = true
  create_role = true
  # create_pipe_role_only         = var.eventbridge_config.create_pipe_role_only
  create_bus = false
  # create_rules                  = var.eventbridge_config.create_rules
  # create_targets                = var.eventbridge_config.create_targets
  # create_permissions            = var.eventbridge_config.create_permissions
  # create_archives               = var.eventbridge_config.create_archives
  # create_connections            = var.eventbridge_config.create_connections
  # create_api_destinations       = var.eventbridge_config.create_api_destinations
  # create_schemas_discoverer     = var.eventbridge_config.create_schemas_discoverer
  # create_schedule_groups        = var.eventbridge_config.create_schedule_groups
  # create_schedules              = var.eventbridge_config.create_schedules
  # create_pipes                  = var.eventbridge_config.create_pipes
  # append_rule_postfix           = var.eventbridge_config.append_rule_postfix
  # append_connection_postfix     = var.eventbridge_config.append_connection_postfix
  # append_destination_postfix    = var.eventbridge_config.append_destination_postfix
  # append_schedule_group_postfix = var.eventbridge_config.append_schedule_group_postfix
  # append_schedule_postfix       = var.eventbridge_config.append_schedule_postfix
  # append_pipe_postfix           = var.eventbridge_config.append_pipe_postfix
  # 
  # bus_name                       = var.eventbridge_config.bus_name
  # bus_description                = var.eventbridge_config.bus_description
  # event_source_name              = var.eventbridge_config.event_source_name
  # kms_key_identifier             = var.eventbridge_config.kms_key_identifier
  # schemas_discoverer_description = var.eventbridge_config.schemas_discoverer_description
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
        name            = "glue-trigger"
        arn             = module.glue_trigger.arn
        attach_role_arn = true
      }
    ]
  }
  # archives                = var.eventbridge_config.archives
  # permissions             = var.eventbridge_config.permissions
  # connections             = var.eventbridge_config.connections
  # api_destinations        = var.eventbridge_config.api_destinations
  # schedule_groups         = var.eventbridge_config.schedule_groups
  # schedules               = var.eventbridge_config.schedules
  # pipes                   = var.eventbridge_config.pipes
  # tags                    = var.eventbridge_config.tags
  # schedule_group_timeouts = var.eventbridge_config.schedule_group_timeouts

  # role_name                  = var.eventbridge_config.role_name
  # role_description           = var.eventbridge_config.role_description
  # role_path                  = var.eventbridge_config.role_path
  # policy_path                = var.eventbridge_config.policy_path
  # role_force_detach_policies = var.eventbridge_config.role_force_detach_policies
  # role_permissions_boundary  = var.eventbridge_config.role_permissions_boundary
  # role_tags                  = var.eventbridge_config.role_tags
  # ecs_pass_role_resources    = var.eventbridge_config.ecs_pass_role_resources

  # attach_kinesis_policy          = var.eventbridge_config.attach_kinesis_policy
  # attach_kinesis_firehose_policy = var.eventbridge_config.attach_kinesis_firehose_policy
  # attach_sqs_policy              = var.eventbridge_config.attach_sqs_policy
  # attach_sns_policy              = var.eventbridge_config.attach_sns_policy
  # attach_ecs_policy              = var.eventbridge_config.attach_ecs_policy
  # attach_lambda_policy           = var.eventbridge_config.attach_lambda_policy
  # attach_sfn_policy              = var.eventbridge_config.attach_sfn_policy
  # attach_cloudwatch_policy       = var.eventbridge_config.attach_cloudwatch_policy
  # attach_api_destination_policy  = var.eventbridge_config.attach_api_destination_policy
  # attach_tracing_policy          = var.eventbridge_config.attach_tracing_policy
  # kinesis_target_arns            = var.eventbridge_config.kinesis_target_arns
  # kinesis_firehose_target_arns   = var.eventbridge_config.kinesis_firehose_target_arns
  # sqs_target_arns                = var.eventbridge_config.sqs_target_arns
  # sns_target_arns                = var.eventbridge_config.sns_target_arns
  # sns_kms_arns                   = var.eventbridge_config.sns_kms_arns
  # ecs_target_arns                = var.eventbridge_config.ecs_target_arns
  # lambda_target_arns             = var.eventbridge_config.lambda_target_arns
  # sfn_target_arns                = var.eventbridge_config.sfn_target_arns
  # cloudwatch_target_arns         = var.eventbridge_config.cloudwatch_target_arns

  # attach_policy_json       = var.eventbridge_config.attach_policy_json
  # attach_policy_jsons      = var.eventbridge_config.attach_policy_jsons
  # attach_policy            = var.eventbridge_config.attach_policy
  # attach_policies          = var.eventbridge_config.attach_policies
  # number_of_policy_jsons   = var.eventbridge_config.number_of_policy_jsons
  # number_of_policies       = var.eventbridge_config.number_of_policies
  attach_policy_statements = true
  # trusted_entities         = var.eventbridge_config.trusted_entities
  # policy_json              = var.eventbridge_config.policy_json
  # policy_jsons             = var.eventbridge_config.policy_jsons
  # policies                 = var.eventbridge_config.policies
  policy_statements = {
    glue = {
      effect    = "Allow",
      actions   = ["glue:StartTrigger"],
      resources = ["${module.glue_trigger.arn}"],
    },
  }
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

  attach_policy_statements = true
  policy_statements = {
    sagemaker = {
      effect    = "Allow",
      actions   = ["sagemaker:StartPipelineExecution"],
      resources = ["${module.sagemaker.sagemaker_pipeline_arn}"],
    },
  }
}

# Sagemaker
module "sagemaker" {
  source = "./modules/terraform-aws-sagemaker"

  s3_data_bucket_name = module.s3["data_source_bucket"].s3_bucket_id
  s3_data_key         = module.s3_object["pre_processing_object"].s3_object_id
  sagemaker_bucket    = module.s3["scripts_source_bucket"].s3_bucket_id
}

#module "lambda_function" {
#  source = "./modules/terraform-aws-lambda"
#
#  function_name = var.lambda_function_config.function_name
#  description   = var.lambda_function_config.description
#
#  handler = "index.lambda_handler"
#  runtime = "python3.12"
#  publish = true
#
#  create_package         = false
#  local_existing_package = var.lambda_function_config.local_existing_package
#
#  attach_policy_statements = true
#  policy_statements = {
#    sagemaker = {
#      effect = "Allow"
#      actions = [
#        "sagemaker:CreateModel",
#        "sagemaker:CreateEndpointConfig",
#        "sagemaker:CreateEndpoint",
#        "sagemaker:UpdateEndpoint"
#      ]
#      resources = ["*"]
#    }
#  }
#}
