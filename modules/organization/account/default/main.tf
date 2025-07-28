resource "random_id" "email_seed" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    ami_id = var.name
  }

  byte_length = 4
}

resource "aws_organizations_account" "default_account" {
  parent_id = var.parent_id

  name  = var.name
  email = "org.acc+${lower(var.name)}-${random_id.email_seed.hex}@pm.me"

  role_name = "${lower(var.name)}-root-role"

  close_on_deletion = true

  lifecycle {
    ignore_changes = [role_name]
  }
}