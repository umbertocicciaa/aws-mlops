terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.11"
    }
  }

  # local
  backend "local" {}

  ## remote
  #backend "s3" {  
  #  bucket       = "tfstate-${terraform.workspace}"
  #  key          = "${terraform.workspace}/terraform.tfstate"  
  #  region       = var.region 
  #  encrypt      = true  
  #  use_lockfile = true 
  #}  
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "${terraform.workspace}"
    }
  }
}
