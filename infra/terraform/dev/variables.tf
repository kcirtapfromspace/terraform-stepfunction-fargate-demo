variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = " the project name"
  type        = string

}

variable "environment" {
  description = "the environment name"
  type        = string

}

variable "vpc_id" {
  description = "the vpc id"
  type        = string

}
