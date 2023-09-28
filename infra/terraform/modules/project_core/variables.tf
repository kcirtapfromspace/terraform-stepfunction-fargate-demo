variable "aws_region" {
   default = "us-east-1"
}

variable "availability_zones" {
   type    = list
   default = ["us-west-1a", "us-west-1b", "us-west-1c"]
}

variable "project" {
  default = "dbt-serverless"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "db_port" {
  default = "5432"
}

variable "db_role" {
  default = "IAM:dbt"
}
variable "db_host" {
  default = "redshift.cluster-xxxxxxxxxxxx.us-east-1.redshift.amazonaws.com"
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
