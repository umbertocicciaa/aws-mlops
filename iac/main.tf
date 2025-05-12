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
  bucket                                          = each.value.bucket
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

# Etl Preprocessing
module "aws_glue_crawler" {
  source   = "./modules/terraform-aws-glue/modules/glue-crawler"
  for_each = var.glue_crawler_config

  database_name          = each.value.database_name
  role                   = each.value.role
  crawler_name           = each.value.crawler_name
  crawler_description    = each.value.crawler_description
  schedule               = each.value.schedule
  classifiers            = each.value.classifiers
  configuration          = each.value.configuration
  jdbc_target            = each.value.jdbc_target
  dynamodb_target        = each.value.dynamodb_target
  s3_target              = each.value.s3_target
  mongodb_target         = each.value.mongodb_target
  catalog_target         = each.value.catalog_target
  delta_target           = each.value.delta_target
  table_prefix           = each.value.table_prefix
  security_configuration = each.value.security_configuration
  schema_change_policy   = each.value.schema_change_policy
  lineage_configuration  = each.value.lineage_configuration
  recrawl_policy         = each.value.recrawl_policy
}

module "aws_glue_catalog" {
  source   = "./modules/terraform-aws-glue/modules/glue-catalog-table"
  for_each = var.glue_catalog_config

  catalog_table_name        = each.value.catalog_table_name
  catalog_table_description = each.value.catalog_table_description
  database_name             = each.value.database_name
  catalog_id                = each.value.catalog_id
  owner                     = each.value.owner
  parameters                = each.value.parameters
  partition_index           = each.value.partition_index
  partition_keys            = each.value.partition_keys
  retention                 = each.value.retention
  table_type                = each.value.table_type
  target_table              = each.value.target_table
  view_expanded_text        = each.value.view_expanded_text
  view_original_text        = each.value.view_original_text
  storage_descriptor        = each.value.storage_descriptor
}

module "aws_glue_etl_job" {
  source   = "./modules/terraform-aws-glue/modules/glue-job"
  for_each = var.glue_job_config

  command                   = each.value.command
  role_arn                  = each.value.role_arn
  job_name                  = each.value.job_name
  job_description           = each.value.job_description
  connections               = each.value.connections
  glue_version              = each.value.glue_version
  default_arguments         = each.value.default_arguments
  non_overridable_arguments = each.value.non_overridable_arguments
  security_configuration    = each.value.security_configuration
  timeout                   = each.value.timeout
  max_capacity              = each.value.max_capacity
  max_retries               = each.value.max_retries
  worker_type               = each.value.worker_type
  number_of_workers         = each.value.number_of_workers
  execution_property        = each.value.execution_property
  notification_property     = each.value.notification_property
}

# events
# module "amazon_eventbridge" {
#   source   = "./modules/terraform-aws-eventbridge"
#   for_each = var.eventbridge_config
# }
# 
# module "aws_lambda" {
#   source = "./modules/terraform-aws-lambda"
# }
# 
# module "aws_sagemaker" {
#   source = "./modules/terraform-aws-sagemaker"
# }