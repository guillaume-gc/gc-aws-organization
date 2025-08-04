# GC AWS Organization

This personal project uses Terraform to create and manage my own AWS Organization using GitHub Actions. It simplifies the process of setting up and managing my AWS accounts, organizational units (OUs), service control policies (SCPs), and other related resources.

**Keep in mind that while project was made as generic as possible, it is still only used for my AWS Organization. It may not work in another environment.**

## FAQ

### Why not using AWS Control Tower?

AWS Control Tower has not been used to reduce the cost of managing this organization, I also wanted to experiment with an AWS Organization purely managed with Terraform.

## Prerequisites

### Tools
- Terraform (>= 1.12.x)
- Git.

### OIDC Provider

Create IAM OIDC provider for AWS (see [GitHub documentation](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) for more information) from a CloudFormation stack using the `scripts/oicd_provider/template.yml` template.

The OIDC Provider is deployed using CloudFormation instead of Terraform to resolve a bootstrapping issue. GitHub Actions requires the OIDC provider to authenticate with AWS, but Terraform cannot create the provider without first being authenticated. CloudFormation breaks this circular dependency while maintaining infrastructure as code practices.

### Enable IAM Identity Center

IAM Identity Center must be manually enabled in the management account, as this cannot be automatically performed by Terraform as of today (2025-08-02).

Also, keep in mind that this project does not create IAM Identity Center Users nor their permissions. It only creates Groups and Permission Sets.

### GitHub Actions

The GitHub Actions pipeline requires the following repository variables to be configured:

| Variable                      | Description                                                                    |
|-------------------------------|--------------------------------------------------------------------------------|
| `CICD_AWS_REGION`             | AWS region for Terraform state storage and default resource deployment.        |
| `CICD_IAM_ROLE`               | ARN of the IAM role used by the OIDC provider for authentication.              |
| `CICD_TERRAFORM_VERSION`      | Version of the Terraform executable to use.                                    |
| `CICD_TERRAFORM_STATE_BUCKET` | S3 bucket name for Terraform state storage.                                    |
| `CICD_SERVICE_NAME`           | Service identifier for resource management (recommended: use repository name). |
| `CICD_NOTIFICATION_EMAIL`     | Email address for deployment notifications and alerts.                         |


## Getting Started

### Installation.

1. Clone this repository:
   ```bash
   git clone https://github.com/guillaume-gc/gc-aws-organization
   ```

### Deploy locally

Please note it is not advised to deploy resources locally in a production environment.

1. Make sure you have valid AWS credentials.

2. Initialize Terraform:
    ```bash
    terraform init -backend-config='key="main.tfstate" region="[[YOUR REGION]]" bucket="[[YOUR BUCKET]]"'
    ```

3. Deploy resources (assuming there is a `tfvars` file with variables):
    ```bash
    terraform deploy
    ```

### CICD Deployment

GitHub actions ensure all commits pushed to the main branch trigger a `terraform apply`.

Make sure the code is correctly formated using `terraform fmt -recursive`, otherwise the CICD will fail.

For now, feature branch deployment is not implemented.
