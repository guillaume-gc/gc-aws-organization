resource "aws_organizations_account" "default_account" {
  parent_id = var.parent_id

  name  = var.name
  email = "org.acc+${lower(var.name)}@pm.me"

  role_name = "${lower(var.name)}-root-role"

  close_on_deletion = true

  lifecycle {
    ignore_changes = [role_name]
  }
}