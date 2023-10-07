variable "aws_region" {
   default = "us-east-1"
}

variable "availability_zones" {
   type    = list
   default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "project" {
  default = "dbt-serverless"
  type =  string
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "db_role" {
  default = "IAM:dbt"
}

variable "db_type" {
  default = "redshift"
}

variable "master_username" {
  default = "root"
}

variable "database_name" {
  default = "dbt"
}

variable "dbt_default_schema" {
  default = "dwh"
}

variable "environment" {
  description = "value for environment (dev, test, prod))"
  default = "dev"
  type =  string
}


# variable "redshift_subnets" {
#   description = "list of subnet ids to be used with redshift"
#   type        = list(any)
# }


# variable "vpc_id" {
#   description = "the id of the VPC where security groups will be created"
#   type        = string
# }

variable "redshift_serverless_publicly_accessible" {
  description = "can the redshift cluster be publicly accessible  - default is true"
  type        = bool
  default     = true
}

variable "redshift_jdbc_creds_seed" {
  description = "seed value for jdbc creds - after secret has been created replace with actual values"
  type        = map(string)
  default = {
    "username" : "seeduser",
    "password" : "Password123"
    # checkov:skip=CKV_SECRET_6: Seed values only. Credentials are not stored in terraform.
  }
}
