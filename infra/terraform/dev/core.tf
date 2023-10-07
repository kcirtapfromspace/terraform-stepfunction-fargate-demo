module "core" {
  source = "../modules/project_core"

  project = var.project
  environment = var.environment
  # vpc_id = var.vpc_id

  
}