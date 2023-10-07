module "data_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"
  
  bucket = "${local.prefix}-data-bucket"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}
module "raw_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"
  
  bucket = "${local.prefix}-raw-bucket"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}
module "staging_bucket" {
    source  = "terraform-aws-modules/s3-bucket/aws"
    version = "3.15.1"
    
    bucket = "${local.prefix}-staging-bucket"
    acl    = "private"
    
    control_object_ownership = true
    object_ownership         = "ObjectWriter"
    
    versioning = {
        enabled = true
    } 
}

module "curated_bucket" {
    source  = "terraform-aws-modules/s3-bucket/aws"
    version = "3.15.1"
    
    bucket = "${local.prefix}-curated-bucket"
    acl    = "private"
    
    control_object_ownership = true
    object_ownership         = "ObjectWriter"
    
    versioning = {
        enabled = true
    } 
}