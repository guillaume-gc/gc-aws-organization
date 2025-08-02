module "infrastructure_ou" {
  source = "../ou/infrastructure"
}

module "security_ou" {
  source           = "../ou/security"
  resources_prefix = var.resources_prefix
}