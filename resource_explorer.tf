resource "aws_resourceexplorer2_index" "global_aggregator" {
  type = "AGGREGATOR"
}

resource "aws_resourceexplorer2_view" "organizational" {
  name = "OrganizationalView"

  scope = aws_organizations_organization.organization.id

  depends_on = [aws_resourceexplorer2_index.global_aggregator]
}