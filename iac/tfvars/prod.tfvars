# s3
s3_config = {
  "scripts_source_bucket" = {
    create_bucket = true
    bucket        = "scripts-bucket"
    force_destroy = true
  },
  "data_source_bucket" = {
    create_bucket = true
    bucket        = "data-source-bucket"
    force_destroy = true
  },
  "pre_processed_data_bucket" = {
    create_bucket = true
    bucket        = "pre-processed-data-bucket"
    force_destroy = true
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

s3_object_dataset_config = {
  create      = true
  key         = "housing.csv"
  file_source = "../dataset/housing.csv"
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

