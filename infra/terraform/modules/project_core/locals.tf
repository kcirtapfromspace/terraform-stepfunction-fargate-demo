locals {
  prefix = "${var.project}-${var.environment}"
  lambda_functions = { # this is a list of the directories where the lambda code lives - used to produce a zip of everything for uploading.
    "example" = "lambda_code/example/"
  }
}