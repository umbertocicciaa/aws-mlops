# s3
s3_config = {
  "scripts_source_bucket" = {
    create_bucket                                   = true
    attach_elb_log_delivery_policy                  = false
    attach_lb_log_delivery_policy                   = false
    attach_access_log_delivery_policy               = false
    attach_deny_insecure_transport_policy           = false
    attach_require_latest_tls_policy                = false
    attach_policy                                   = false
    attach_public_policy                            = false
    attach_inventory_destination_policy             = false
    attach_analytics_destination_policy             = false
    attach_deny_incorrect_encryption_headers        = false
    attach_deny_incorrect_kms_key_sse               = false
    allowed_kms_key_arn                             = null
    attach_deny_unencrypted_object_uploads          = false
    attach_deny_ssec_encrypted_object_uploads       = false
    bucket                                          = "scripts-bucket"
    acl                                             = null
    policy                                          = null
    tags                                            = {}
    force_destroy                                   = true
    acceleration_status                             = null
    request_payer                                   = null
    website                                         = {}
    cors_rule                                       = []
    versioning                                      = {}
    logging                                         = {}
    access_log_delivery_policy_source_buckets       = []
    access_log_delivery_policy_source_accounts      = []
    access_log_delivery_policy_source_organizations = []
    lb_log_delivery_policy_source_organizations     = []
    grant                                           = []
    owner                                           = {}
    expected_bucket_owner                           = null
    transition_default_minimum_object_size          = null
    lifecycle_rule                                  = []
    replication_configuration                       = {}
    server_side_encryption_configuration            = {}
    intelligent_tiering                             = {}
    object_lock_configuration                       = {}
    metric_configuration                            = []
    inventory_configuration                         = {}
    inventory_source_account_id                     = null
    inventory_source_bucket_arn                     = null
    inventory_self_source_destination               = false
    analytics_configuration                         = {}
    analytics_source_account_id                     = null
    analytics_source_bucket_arn                     = null
    analytics_self_source_destination               = false
    object_lock_enabled                             = false
    block_public_acls                               = true
    block_public_policy                             = true
    ignore_public_acls                              = true
    restrict_public_buckets                         = true
    control_object_ownership                        = false
    object_ownership                                = "BucketOwnerEnforced"

    is_directory_bucket  = false
    data_redundancy      = null
    availability_zone_id = null
    location_type        = null
  },
  "data_source_bucket" = {
    create_bucket                                   = true
    attach_elb_log_delivery_policy                  = false
    attach_lb_log_delivery_policy                   = false
    attach_access_log_delivery_policy               = false
    attach_deny_insecure_transport_policy           = false
    attach_require_latest_tls_policy                = false
    attach_policy                                   = false
    attach_public_policy                            = false
    attach_inventory_destination_policy             = false
    attach_analytics_destination_policy             = false
    attach_deny_incorrect_encryption_headers        = false
    attach_deny_incorrect_kms_key_sse               = false
    allowed_kms_key_arn                             = null
    attach_deny_unencrypted_object_uploads          = false
    attach_deny_ssec_encrypted_object_uploads       = false
    bucket                                          = "data-source-bucket"
    acl                                             = null
    policy                                          = null
    tags                                            = {}
    force_destroy                                   = true
    acceleration_status                             = null
    request_payer                                   = null
    website                                         = {}
    cors_rule                                       = []
    versioning                                      = {}
    logging                                         = {}
    access_log_delivery_policy_source_buckets       = []
    access_log_delivery_policy_source_accounts      = []
    access_log_delivery_policy_source_organizations = []
    lb_log_delivery_policy_source_organizations     = []
    grant                                           = []
    owner                                           = {}
    expected_bucket_owner                           = null
    transition_default_minimum_object_size          = null
    lifecycle_rule                                  = []
    replication_configuration                       = {}
    server_side_encryption_configuration            = {}
    intelligent_tiering                             = {}
    object_lock_configuration                       = {}
    metric_configuration                            = []
    inventory_configuration                         = {}
    inventory_source_account_id                     = null
    inventory_source_bucket_arn                     = null
    inventory_self_source_destination               = false
    analytics_configuration                         = {}
    analytics_source_account_id                     = null
    analytics_source_bucket_arn                     = null
    analytics_self_source_destination               = false
    object_lock_enabled                             = false
    block_public_acls                               = true
    block_public_policy                             = true
    ignore_public_acls                              = true
    restrict_public_buckets                         = true
    control_object_ownership                        = false
    object_ownership                                = "BucketOwnerEnforced"

    is_directory_bucket  = false
    data_redundancy      = null
    availability_zone_id = null
    location_type        = null
  },
  "pre_processed_data_bucket" = {
    create_bucket                                   = true
    attach_elb_log_delivery_policy                  = false
    attach_lb_log_delivery_policy                   = false
    attach_access_log_delivery_policy               = false
    attach_deny_insecure_transport_policy           = false
    attach_require_latest_tls_policy                = false
    attach_policy                                   = false
    attach_public_policy                            = false
    attach_inventory_destination_policy             = false
    attach_analytics_destination_policy             = false
    attach_deny_incorrect_encryption_headers        = false
    attach_deny_incorrect_kms_key_sse               = false
    allowed_kms_key_arn                             = null
    attach_deny_unencrypted_object_uploads          = false
    attach_deny_ssec_encrypted_object_uploads       = false
    bucket                                          = "pre-processed-data-bucket"
    acl                                             = null
    policy                                          = null
    tags                                            = {}
    force_destroy                                   = true
    acceleration_status                             = null
    request_payer                                   = null
    website                                         = {}
    cors_rule                                       = []
    versioning                                      = {}
    logging                                         = {}
    access_log_delivery_policy_source_buckets       = []
    access_log_delivery_policy_source_accounts      = []
    access_log_delivery_policy_source_organizations = []
    lb_log_delivery_policy_source_organizations     = []
    grant                                           = []
    owner                                           = {}
    expected_bucket_owner                           = null
    transition_default_minimum_object_size          = null
    lifecycle_rule                                  = []
    replication_configuration                       = {}
    server_side_encryption_configuration            = {}
    intelligent_tiering                             = {}
    object_lock_configuration                       = {}
    metric_configuration                            = []
    inventory_configuration                         = {}
    inventory_source_account_id                     = null
    inventory_source_bucket_arn                     = null
    inventory_self_source_destination               = false
    analytics_configuration                         = {}
    analytics_source_account_id                     = null
    analytics_source_bucket_arn                     = null
    analytics_self_source_destination               = false
    object_lock_enabled                             = false
    block_public_acls                               = true
    block_public_policy                             = true
    ignore_public_acls                              = true
    restrict_public_buckets                         = true
    control_object_ownership                        = false
    object_ownership                                = "BucketOwnerEnforced"

    is_directory_bucket  = false
    data_redundancy      = null
    availability_zone_id = null
    location_type        = null
  }
}

s3_object_config = {
  "pre_processing_object" = {
    create      = true
    key         = "pre_processing.py"
    file_source = "../data-preprocessing/pre_processing.py"
  },
  "training_py" = {
    create      = true
    key         = "training.py"
    file_source = "../pipeline/training.py"
  },
  "evaluate_py" = {
    create      = true
    key         = "evaluate.py"
    file_source = "../pipeline/evaluate.py"
  }
}

# glue
glue_catalog_database_config = {
  catalog_database_name        = "housings"
  catalog_database_description = "Glue Catalog database for the data located in raw data source bucket"
}

glue_catalog_table_config = {
  catalog_table_name        = "housings_table"
  catalog_table_description = "Glue Catalog table for the data located in raw data source bucket"
}

glue_crawler_config = {
  crawler_name        = "prod-crawler-elt-preprocessing"
  crawler_description = "Crawler for ETL Preprocessing"
  schedule            = "cron(0 1 * * ? *)"
  schema_change_policy = {
    delete_behavior = "LOG"
    update_behavior = null
  }
}

glue_workflow_config = {
  name                = "prod-workflow-elt-preprocessing"
  description         = "Workflow for ETL Preprocessing"
  max_concurrent_runs = 4
}

glue_job_config = {
  job_name          = "prod-job-elt-preprocessing"
  job_description   = "Job for ETL Preprocessing"
  glue_version      = "2.0"
  timeout           = 20
  max_retries       = 2
  worker_type       = "Standard"
  number_of_workers = 2
}

# eventbridge
eventbridge_config = {
  role_name = "prod-eventbridge-glue"
}

eventbridge_mlops_config = {
  role_name = "prod-eventbridge-mlops"
}

