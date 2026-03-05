# Nebula Cloud Platform

Enterprise-grade cloud infrastructure and platform engineering meta-repository using Azure.

## Overview

Nebula Cloud Platform provides reusable Terraform modules for deploying cloud infrastructure on Azure, including:
- Azure Kubernetes Service (AKS)
- Virtual Networks with subnets
- Azure SQL Database
- Azure Cache for Redis
- Azure Functions
- Azure Storage
- Azure Key Vault

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Virtual Network                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐   │
│  │ AKS Cluster │  │ App Services│  │ SQL Database    │   │
│  │             │  │ (Functions) │  │                 │   │
│  └─────────────┘  └─────────────┘  └─────────────────┘   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐   │
│  │ Redis Cache │  │   Storage   │  │   Key Vault     │   │
│  └─────────────┘  └─────────────┘  └─────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Module Structure

```
nebula-cloud-platform/
├── modules/
│   ├── vnet/          # Virtual Network and subnets
│   ├── aks/           # Azure Kubernetes Service
│   ├── sql/           # Azure SQL Database
│   ├── redis/         # Azure Cache for Redis
│   ├── functions/     # Azure Functions
│   ├── storage/      # Azure Storage Account
│   └── keyvault/     # Azure Key Vault
├── .github/
│   └── workflows/    # Terraform CI/CD pipelines
├── main.tf           # Root module
├── variables.tf      # Root variables
├── outputs.tf        # Root outputs
└── README.md
```

## Getting Started

### Prerequisites

- Azure subscription
- Terraform >= 1.5.0
- Azure CLI
- Git

### Quick Start

1. Clone the repository
2. Create a `terraform.tfvars` file:
   ```hcl
   resource_group_name = "nebula-rg"
   location = "eastus"
   ```
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Plan the infrastructure:
   ```bash
   terraform plan
   ```
5. Apply the infrastructure:
   ```bash
   terraform apply
   ```

## Modules

### VNet Module
Creates virtual network with subnets, NSGs, and route tables.

### AKS Module
Creates Kubernetes cluster with:
- System and user node pools
- Azure AD integration
- Azure Monitor
- Key Vault secrets provider

### SQL Module
Creates Azure SQL Server with databases, elastic pools, and firewall rules.

### Redis Module
Creates Azure Cache for Redis with clustering support.

### Functions Module
Creates Azure Functions with App Service Plan and storage.

### Storage Module
Creates Storage Account with containers, queues, and tables.

### Key Vault Module
Creates Key Vault with secrets, keys, and access policies.

## CI/CD

The repository includes GitHub Actions workflows for:
- Terraform validation and formatting
- Security scanning (Checkov, tfsec)
- Terraform plan/apply

## Security

- All resources use private endpoints where possible
- RBAC enabled for AKS and Key Vault
- Network security groups with restrictive rules
- Secrets stored in Key Vault
- TLS 1.2+ enforced

## Cost Optimization

- Auto-scaling enabled for AKS node pools
- Right-sized SKUs
- Reserved capacity recommendations
- Budget alerts configured

## License

MIT
