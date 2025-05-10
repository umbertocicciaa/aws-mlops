module "backend" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "tfstate-${terraform.workspace}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

