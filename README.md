# GC AWS Organization

This personal project uses Terraform to create and manage my own AWS Organization using GitHub Actions. It simplifies the process of setting up and managing my AWS accounts, organizational units (OUs), service control policies (SCPs), and other related resources.

**Keep in mind this project was made for a specific AWS Organization. A lot of static values such as S3 bucket names or account IDs will not work in another Organization.**

## Prerequisites

### Tools
- Terraform (>= 1.9.x)
- Git.

### OIDC Provider

Create IAM OIDC provider for AWS (see [GitHub documentation](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) for more information) from a CloudFormation stack using the `scripts/oicd_provider/template.yml` template.

The OIDC Provider is deployed using CloudFormation rather than Terraform to resolve a fundamental bootstrapping problem. Since this project relies on GitHub Actions to deploy infrastructure via Terraform, it requires an existing AWS IAM OIDC identity provider to authenticate and assume the necessary IAM roles. However, without this provider already existing in AWS, GitHub Actions cannot authenticate to deploy any resources, including the OIDC provider itself. This creates a circular dependency where Terraform cannot run without the OIDC provider, but the OIDC provider cannot be created by Terraform. Manually creating the OIDC provider solves the problem, and CloudFormation is used to ensure this is done using IaC.

## Getting Started

### Installation
1. Clone this repository and move to its root:
   ```bash
   git clone https://github.com/guillaume-gc/gc-aws-organization;
   cd gc-aws-organization
   ```
2. Make sure you have valid AWS credentials.

3. Initialize Terraform:
    ```bash
    terraform init -backend-config="key=$(git rev-parse --abbrev-ref HEAD).tfvars"
    ```
(`git rev-parse --abbrev-ref HEAD` returns the checked-in Git branch name.)

### Deployment

GitHub actions ensure all commits pushed to main trigger a `terraform apply`.