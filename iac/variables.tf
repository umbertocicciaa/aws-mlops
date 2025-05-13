variable "region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "eu-west-3"
}

variable "s3_config" {
  description = "S3 bucket configurations."
  type = map(object({
    create_bucket                                   = optional(bool, true)
    attach_elb_log_delivery_policy                  = optional(bool, false)
    attach_lb_log_delivery_policy                   = optional(bool, false)
    attach_access_log_delivery_policy               = optional(bool, false)
    attach_deny_insecure_transport_policy           = optional(bool, false)
    attach_require_latest_tls_policy                = optional(bool, false)
    attach_policy                                   = optional(bool, false)
    attach_public_policy                            = optional(bool, true)
    attach_inventory_destination_policy             = optional(bool, false)
    attach_analytics_destination_policy             = optional(bool, false)
    attach_deny_incorrect_encryption_headers        = optional(bool, false)
    attach_deny_incorrect_kms_key_sse               = optional(bool, false)
    allowed_kms_key_arn                             = optional(string, null)
    attach_deny_unencrypted_object_uploads          = optional(bool, false)
    attach_deny_ssec_encrypted_object_uploads       = optional(bool, false)
    bucket                                          = optional(string, null)
    bucket_prefix                                   = optional(string, null)
    acl                                             = optional(string, null)
    policy                                          = optional(string, null)
    tags                                            = optional(map(string), {})
    force_destroy                                   = optional(bool, false)
    acceleration_status                             = optional(string, null)
    request_payer                                   = optional(string, null)
    website                                         = optional(any, {})
    cors_rule                                       = optional(any, [])
    versioning                                      = optional(map(string), {})
    logging                                         = optional(any, {})
    access_log_delivery_policy_source_buckets       = optional(list(string), [])
    access_log_delivery_policy_source_accounts      = optional(list(string), [])
    access_log_delivery_policy_source_organizations = optional(list(string), [])
    lb_log_delivery_policy_source_organizations     = optional(list(string), [])
    grant                                           = optional(any, [])
    owner                                           = optional(map(string), {})
    expected_bucket_owner                           = optional(string, null)
    transition_default_minimum_object_size          = optional(string, null)
    lifecycle_rule                                  = optional(any, [])
    replication_configuration                       = optional(any, {})
    server_side_encryption_configuration            = optional(any, {})
    intelligent_tiering                             = optional(any, {})
    object_lock_configuration                       = optional(any, {})
    metric_configuration                            = optional(any, [])
    inventory_configuration                         = optional(any, {})
    inventory_source_account_id                     = optional(string, null)
    inventory_source_bucket_arn                     = optional(string, null)
    inventory_self_source_destination               = optional(bool, false)
    analytics_configuration                         = optional(any, {})
    analytics_source_account_id                     = optional(string, null)
    analytics_source_bucket_arn                     = optional(string, null)
    analytics_self_source_destination               = optional(bool, false)
    object_lock_enabled                             = optional(bool, false)
    block_public_acls                               = optional(bool, true)
    block_public_policy                             = optional(bool, true)
    ignore_public_acls                              = optional(bool, true)
    restrict_public_buckets                         = optional(bool, true)
    control_object_ownership                        = optional(bool, false)
    object_ownership                                = optional(string, "BucketOwnerEnforced")

    is_directory_bucket  = optional(bool, false)
    data_redundancy      = optional(string, null)
    type                 = optional(string, "Directory")
    availability_zone_id = optional(string, null)
    location_type        = optional(string, null)
  }))
  default = {}
}

variable "s3_object_config" {
  description = "S3 object configurations."
  type = map(object({
    create                        = optional(bool, true)
    bucket                        = optional(string, "")
    key                           = optional(string, "")
    file_source                   = optional(string, null)
    content                       = optional(string, null)
    content_base64                = optional(string, null)
    acl                           = optional(string, null)
    cache_control                 = optional(string, null)
    content_disposition           = optional(string, null)
    content_encoding              = optional(string, null)
    content_language              = optional(string, null)
    content_type                  = optional(string, null)
    website_redirect              = optional(string, null)
    storage_class                 = optional(string, null)
    etag                          = optional(string, null)
    server_side_encryption        = optional(string, null)
    kms_key_id                    = optional(string, null)
    bucket_key_enabled            = optional(bool, null)
    metadata                      = optional(map(string), {})
    tags                          = optional(map(string), {})
    force_destroy                 = optional(bool, false)
    object_lock_legal_hold_status = optional(string, null)
    object_lock_mode              = optional(string, null)
    object_lock_retain_until_date = optional(string, null)
    source_hash                   = optional(string, null)
    override_default_tags         = optional(bool, false)
  }))
  default = {}
}

variable "glue_crawler_config" {
  description = "Glue crawler configurations."
  type = map(object({
    crawler_name        = optional(string, null)
    crawler_description = optional(string, null)
    database_name       = string
    role                = string
    schedule            = optional(string, null)
    classifiers         = optional(list(string), null)
    configuration       = optional(string, null)
    jdbc_target         = optional(list(any), null)
    #  type = list(object({
    #    connection_name = string
    #    path            = string
    #    exclusions      = list(string)
    #  }))
    dynamodb_target = optional(list(any), null)
    #  type = list(object({
    #    path      = string
    #    scan_all  = bool
    #    scan_rate = number
    #  }))
    s3_target = optional(list(any), null)
    #  type = list(object({
    #    path                = string
    #    connection_name     = string
    #    exclusions          = list(string)
    #    sample_size         = number
    #    event_queue_arn     = string
    #    dlq_event_queue_arn = string
    #  }))
    mongodb_target = optional(list(any), null)
    #  type = list(object({
    #    connection_name = string
    #    path            = string
    #    scan_all        = bool
    #  }))
    catalog_target = optional(list(object({
      database_name = string
      tables        = list(string)
    })), null)
    delta_target = optional(list(object({
      connection_name = string
      write_manifest  = bool
      delta_tables    = list(string)
    })), null)
    table_prefix           = optional(string, null)
    security_configuration = optional(string, null)
    schema_change_policy   = optional(map(string), null)
    #  type = object({
    #    delete_behavior = string
    #    update_behavior = string
    #  })
    lineage_configuration = optional(object({
      crawler_lineage_settings = string
    }), null)
    recrawl_policy = optional(object({
      recrawl_behavior = string
    }))
  }))
  default = {}
}

variable "glue_job_config" {
  description = "Glue job configurations."
  type = map(object({
    job_name                  = optional(string)
    job_description           = optional(string)
    role_arn                  = string
    connections               = optional(list(string))
    glue_version              = optional(string, "2.0")
    default_arguments         = optional(map(string))
    non_overridable_arguments = optional(map(string))
    security_configuration    = optional(string)
    timeout                   = optional(number, 2880)
    max_capacity              = optional(number)
    max_retries               = optional(number)
    worker_type               = optional(string)
    number_of_workers         = optional(number)
    command                   = map(any)
    #  type = object({
    #    # The name of the job command. Defaults to `glueetl`.
    #    # Use `pythonshell` for Python Shell Job Type, or `gluestreaming` for Streaming Job Type.
    #    name = string
    #    # Specifies the S3 path to a script that executes the job
    #    script_location = string
    #    # The Python version being used to execute a Python shell job. Allowed values are 2 or 3
    #    python_version = number
    #  })
    execution_property = optional(object({
      max_concurrent_runs = number
    }))
    notification_property = optional(object({
      notify_delay_after = number
    }))
  }))
  default = {}
}

variable "glue_catalog_config" {
  description = "Glue catalog configurations."
  type = map(object({
    catalog_table_name        = optional(string, null)
    catalog_table_description = optional(string, null)
    database_name             = string
    catalog_id                = optional(string, null)
    owner                     = optional(string, null)
    parameters                = optional(map(string), null)
    partition_index = optional(object({
      index_name = string
      keys       = list(string)
    }), null)
    partition_keys = optional(map(any), {})
    #  type = object({
    #    comment = string
    #    name    = string
    #    type    = string
    #  })
    retention  = optional(number, null)
    table_type = optional(string, null)
    target_table = optional(object({
      catalog_id    = string
      database_name = string
      name          = string
    }), null)
    view_expanded_text = optional(string, null)
    view_original_text = optional(string, null)
    storage_descriptor = optional(any, null)
    #  type = object({
    #    # List of reducer grouping columns, clustering columns, and bucketing columns in the table
    #    bucket_columns = list(string)
    #    # Configuration block for columns in the table
    #    columns = list(object({
    #      comment    = string
    #      name       = string
    #      parameters = map(string)
    #      type       = string
    #    }))
    #    # Whether the data in the table is compressed
    #    compressed = bool
    #    # Input format: SequenceFileInputFormat (binary), or TextInputFormat, or a custom format
    #    input_format = string
    #    # Physical location of the table. By default this takes the form of the warehouse location, followed by the database location in the warehouse, followed by the table name
    #    location = string
    #    #  Must be specified if the table contains any dimension columns
    #    number_of_buckets = number
    #    # Output format: SequenceFileOutputFormat (binary), or IgnoreKeyTextOutputFormat, or a custom format
    #    output_format = string
    #    # User-supplied properties in key-value form
    #    parameters = map(string)
    #    # Object that references a schema stored in the AWS Glue Schema Registry
    #    # When creating a table, you can pass an empty list of columns for the schema, and instead use a schema reference
    #    schema_reference = object({
    #      # Configuration block that contains schema identity fields. Either this or the schema_version_id has to be provided
    #      schema_id = object({
    #        # Name of the schema registry that contains the schema. Must be provided when schema_name is specified and conflicts with schema_arn
    #        registry_name = string
    #        # ARN of the schema. One of schema_arn or schema_name has to be provided
    #        schema_arn = string
    #        # Name of the schema. One of schema_arn or schema_name has to be provided
    #        schema_name = string
    #      })
    #      # Unique ID assigned to a version of the schema. Either this or the schema_id has to be provided
    #      schema_version_id     = string
    #      schema_version_number = number
    #    })
    #    # Configuration block for serialization and deserialization ("SerDe") information
    #    ser_de_info = object({
    #      # Name of the SerDe
    #      name = string
    #      # Map of initialization parameters for the SerDe, in key-value form
    #      parameters = map(string)
    #      # Usually the class that implements the SerDe. An example is org.apache.hadoop.hive.serde2.columnar.ColumnarSerDe
    #      serialization_library = string
    #    })
    #    # Configuration block with information about values that appear very frequently in a column (skewed values)
    #    skewed_info = object({
    #      # List of names of columns that contain skewed values
    #      skewed_column_names = list(string)
    #      # List of values that appear so frequently as to be considered skewed
    #      skewed_column_value_location_maps = list(string)
    #      # Map of skewed values to the columns that contain them
    #      skewed_column_values = map(string)
    #    })
    #    # Configuration block for the sort order of each bucket in the table
    #    sort_columns = object({
    #      # Name of the column
    #      column = string
    #      # Whether the column is sorted in ascending (1) or descending order (0)
    #      sort_order = number
    #    })
    #    # Whether the table data is stored in subdirectories
    #    stored_as_sub_directories = bool
    #  })
  }))
  default = {}
}

variable "eventbridge_config" {
  description = "S3 bucket configurations."
  type = map(object({
    create                        = optional(bool, true)
    create_role                   = optional(bool, true)
    create_pipe_role_only         = optional(bool, false)
    create_bus                    = optional(bool, true)
    create_rules                  = optional(bool, true)
    create_targets                = optional(bool, true)
    create_permissions            = optional(bool, true)
    create_archives               = optional(bool, false)
    create_connections            = optional(bool, false)
    create_api_destinations       = optional(bool, false)
    create_schemas_discoverer     = optional(bool, false)
    create_schedule_groups        = optional(bool, true)
    create_schedules              = optional(bool, true)
    create_pipes                  = optional(bool, true)
    append_rule_postfix           = optional(bool, true)
    append_connection_postfix     = optional(bool, true)
    append_destination_postfix    = optional(bool, true)
    append_schedule_group_postfix = optional(bool, true)
    append_schedule_postfix       = optional(bool, true)
    append_pipe_postfix           = optional(bool, true)

    bus_name                       = optional(string, "default")
    bus_description                = optional(string, null)
    event_source_name              = optional(string, null)
    kms_key_identifier             = optional(string, null)
    schemas_discoverer_description = optional(string, "Auto schemas discoverer event")
    rules                          = optional(map(any), {})
    targets                        = optional(any, {})
    archives                       = optional(map(any), {})
    permissions                    = optional(map(any), {})
    connections                    = optional(any, {})
    api_destinations               = optional(map(any), {})
    schedule_groups                = optional(any, {})
    schedules                      = optional(map(any), {})
    pipes                          = optional(any, {})
    tags                           = optional(map(string), {})
    schedule_group_timeouts        = optional(map(string), {})

    role_name                  = optional(string, null)
    role_description           = optional(string, null)
    role_path                  = optional(string, null)
    policy_path                = optional(string, null)
    role_force_detach_policies = optional(bool, true)
    role_permissions_boundary  = optional(string, null)
    role_tags                  = optional(map(string), {})
    ecs_pass_role_resources    = optional(list(string), [])

    attach_kinesis_policy          = optional(bool, false)
    attach_kinesis_firehose_policy = optional(bool, false)
    attach_sqs_policy              = optional(bool, false)
    attach_sns_policy              = optional(bool, false)
    attach_ecs_policy              = optional(bool, false)
    attach_lambda_policy           = optional(bool, false)
    attach_sfn_policy              = optional(bool, false)
    attach_cloudwatch_policy       = optional(bool, false)
    attach_api_destination_policy  = optional(bool, false)
    attach_tracing_policy          = optional(bool, false)
    kinesis_target_arns            = optional(list(string), [])
    kinesis_firehose_target_arns   = optional(list(string), [])
    sqs_target_arns                = optional(list(string), [])
    sns_target_arns                = optional(list(string), [])
    sns_kms_arns                   = optional(list(string), ["*"])
    ecs_target_arns                = optional(list(string), [])
    lambda_target_arns             = optional(list(string), [])
    sfn_target_arns                = optional(list(string), [])
    cloudwatch_target_arns         = optional(list(string), [])

    attach_policy_json       = optional(bool, false)
    attach_policy_jsons      = optional(bool, false)
    attach_policy            = optional(bool, false)
    attach_policies          = optional(bool, false)
    number_of_policy_jsons   = optional(number, 0)
    number_of_policies       = optional(number, 0)
    attach_policy_statements = optional(bool, false)
    trusted_entities         = optional(list(string), [])
    policy_json              = optional(string, null)
    policy_jsons             = optional(list(string), [])
    policies                 = optional(list(string), [])
    policy_statements        = optional(any, {})

  }))
  default = {}
}

variable "vpc_endpoints_config" {
  description = "Vpc endpoints configurations."
  type = map(object({
    create                     = optional(bool, true)
    vpc_id                     = optional(string, null)
    endpoints                  = optional(any, {})
    security_group_ids         = optional(list(string), [])
    subnet_ids                 = optional(list(string), [])
    tags                       = optional(map(string), {})
    create_security_group      = optional(bool, false)
    security_group_name        = optional(string, null)
    security_group_name_prefix = optional(string, null)
    security_group_description = optional(string, null)
    security_group_rules       = optional(any, {})
    security_group_tags        = optional(map(string), {})
    route_table_ids            = optional(list(string), [])
  }))
  default = {}
}

variable "sagemaker_config" {
  description = "SageMaker configurations."
  type        = object({})
  default     = {}
}

