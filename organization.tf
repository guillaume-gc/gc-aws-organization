import {
  to = aws_organizations_organization.organization
  id = "o-iwno6geb2w"
}

import {
  to = aws_organizations_organizational_unit.security
  id = "ou-ixhm-1sf3rpz1"
}

import {
  to = aws_organizations_organizational_unit.infrastructure
  id = "ou-ixhm-0qvmcx39"
}

resource "aws_organizations_organization" "organization" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "account.amazonaws.com",
    "ram.amazonaws.com",
    "sso.amazonaws.com", // IAM Identity Center.
  ]

  feature_set = "ALL"
}

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.organization.roots[0].id
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = aws_organizations_organization.organization.roots[0].id
}