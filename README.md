# GC AWS Organization

This project uses Terraform to create and manage my own AWS Organization using GitHub Actions. It simplifies the process of setting up and managing my AWS accounts, organizational units (OUs), service control policies (SCPs), and other related resources.

## Prerequisites
1. Terraform
    - Make sure to install Terraform (>= 1.9.x) as it is the primary tool used in this setup.

2. Git.

## Getting Started

### Installation
1. Clone this repository:
    ```bash
    git clone https://github.com/yourusername/aws-organization-infra.git
    cd aws-organization-infra
    ```
2. Make sure you have valid AWS credentials.

3. Initialize Terraform:
    ```bash
    terraform init -backend-config="key=$(git rev-parse --abbrev-ref HEAD).tfvars"
    ```
(`git rev-parse --abbrev-ref HEAD` returns the checked-in Git branch name.)

### Deployment

This project is deployed remotely using GitHub Actions and a [GitHub OIDC Provider for AWS](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) to generate temporary credentials.