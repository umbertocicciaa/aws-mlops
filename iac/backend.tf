resource "random_id" "server" {
  byte_length = 4
}

module "backend" {
  source = "./modules/terraform-aws-s3-bucket"

  bucket = "tfstate-${terraform.workspace}-${random_id.server.hex}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

