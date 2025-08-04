output "account_id" {
  value = aws_organizations_account.account.id
}

output "account_arn" {
  value = aws_organizations_account.account.arn
}

output "account_role_name" {
  value = aws_organizations_account.account.role_name
}