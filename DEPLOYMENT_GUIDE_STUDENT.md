# Azure Student Account Deployment Guide - No Cost Strategy

## Overview
This guide provides step-by-step instructions to deploy Nebula Cloud Platform, Genesis Platform Engineering, and Aurora Fullstack SaaS **sequentially** using Azure Free Tier services. All deployments will be demonstrated using **free-tier SKUs only**.

---

## Phase 1: Azure Student Account Setup

### 1.1 Prerequisites
- [ ] Valid .edu email address
- [ ] Azure Student Account created
- [ ] Azure CLI installed (`az --version`)
- [ ] Terraform installed (v1.5+)
- [ ] kubectl installed
- [ ] Git installed

### 1.2 Login and Subscription Setup
```bash
# Login to Azure
az login

# List subscriptions
az account list

# Set default subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Verify free tier eligibility
az account show --query "{name:name, type:user, state:state}"
```

### 1.3 Enable Free Tier Services
```bash
# Register required resource providers
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.Sql
az provider register --namespace Microsoft.Cache
az provider register --namespace Microsoft.Storage
```

---

## Phase 2: Nebula Cloud Platform Deployment

### 2.1 Free-Tier Configuration
Create `terraform.tfvars`:
```hcl
# terraform.tfvars - FREE TIER OPTIMIZED
resource_group_name = "nebula-student-rg"
location            = "eastus"  # Cheapest region

# Minimal sizing for free tier
aks_vm_size         = "Standard_B2s"    # Cheapest VM
aks_node_count      = 1                  # Minimal nodes
sql_sku             = "Free"             # FREE TIER
redis_sku           = "Basic"            # Minimal cache
storage_tier        = "Standard"         # Cheaper storage

# Cost controls
enable_monitoring   = false              # Skip Log Analytics
enable_backups      = false              # Skip backup costs
```

### 2.2 Deployment Steps
```bash
# 1. Clone repository
git clone https://github.com/nithin12342/nebula-cloud-platform.git
cd nebula-cloud-platform

# 2. Initialize Terraform
terraform init

# 3. Validate configuration
terraform plan -out=tfplan

# 4. Review estimated costs
terraform plan | grep -i "resource"

# 5. Apply infrastructure (SCREEN RECORD FROM HERE)
terraform apply tfplan

# 6. Verify deployment
terraform output
az group show --name nebula-student-rg

# 7. Get AKS credentials
az aks get-credentials --resource-group nebula-student-rg --name nebula-aks

# 8. Verify AKS cluster
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces
```

### 2.3 Cost Verification
```bash
# Check resource costs
az costmanagement query \
  --scope "/subscriptions/YOUR_SUBSCRIPTION_ID" \
  --timeframe "MonthToDate" \
  --granularity "Monthly" \
  --metrics "PreTaxCost"
```

### 2.4 Documentation for Phase 2
**Record these outputs:**
- `terraform output` results
- `kubectl cluster-info` output
- Resource group overview screenshot
- Cost analysis screenshot

---

## Phase 3: Genesis Platform Engineering Deployment

### 3.1 Prerequisites for Genesis
```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install ArgoCD (lightweight version)
kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd \
  --namespace argocd \
  --set server.service.type=LoadBalancer \
  --values values-minimal.yaml
```

### 3.2 Create Minimal Backstage Deployment
```bash
# Create namespace
kubectl create namespace platform

# Deploy Backstage using Docker image
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backstage
  namespace: platform
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backstage
  template:
    metadata:
      labels:
        app: backstage
    spec:
      containers:
      - name: backstage
        image: backstage:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "250m"
---
apiVersion: v1
kind: Service
metadata:
  name: backstage
  namespace: platform
spec:
  type: LoadBalancer
  selector:
    app: backstage
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
EOF
```

### 3.3 Deploy ArgoCD Applications
```bash
# Get ArgoCD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)

# Get ArgoCD LoadBalancer IP
ARGOCD_IP=$(kubectl -n argocd get service argocd-server \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "ArgoCD Server: https://$ARGOCD_IP"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"

# Login via CLI
argocd login $ARGOCD_IP --username admin --password $ARGOCD_PASSWORD

# Create sample application
argocd app create genesis-platform \
  --repo https://github.com/nithin12342/genesis-platform-engineering \
  --path configs \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace platform
```

### 3.4 Verify Genesis Deployment
```bash
# Check ArgoCD applications
argocd app list

# Check Kubernetes resources
kubectl get all -n platform
kubectl get all -n argocd

# Port forward to Backstage
kubectl port-forward -n platform service/backstage 3000:80

# Port forward to ArgoCD
kubectl port-forward -n argocd service/argocd-server 8080:443
```

### 3.5 Documentation for Phase 3
**Record screenshots/logs:**
- ArgoCD login screen
- ArgoCD applications list
- Backstage portal (http://localhost:3000)
- kubectl outputs for resources
- Resource group updated costs

---

## Phase 4: Aurora Fullstack SaaS Deployment

### 4.1 Frontend Deployment (Micro-frontend Shell)
```bash
# Clone Aurora repository
git clone https://github.com/nithin12342/aurora-fullstack-saas.git
cd aurora-fullstack-saas

# Install dependencies
npm install

# Create production build
npm run build --workspace=apps/shell-host

# Create Azure Container Registry (FREE during preview)
REGISTRY_NAME="aurorastudent"
az acr create --resource-group nebula-student-rg \
  --name $REGISTRY_NAME \
  --sku Basic

# Build and push Docker image
az acr build --registry $REGISTRY_NAME \
  --image aurora-shell:latest apps/shell-host
```

### 4.2 Backend Deployment (API Gateway)
```bash
# Create Python environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
cd services/api-gateway
pip install -r requirements.txt

# Create Azure App Service (FREE tier)
az appservice plan create \
  --name aurora-plan \
  --resource-group nebula-student-rg \
  --sku F1  # FREE TIER

# Deploy FastAPI application
az webapp create \
  --name aurora-api \
  --resource-group nebula-student-rg \
  --plan aurora-plan \
  --runtime "PYTHON:3.11"

# Push code to App Service
az webapp deployment source config-zip \
  --resource-group nebula-student-rg \
  --name aurora-api \
  --src api-gateway.zip
```

### 4.3 Deploy Frontend Container to AKS
```bash
# Create namespace
kubectl create namespace aurora

# Create secret for ACR
az acr credential show \
  --resource-group nebula-student-rg \
  --name $REGISTRY_NAME

# Deploy to AKS
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aurora-shell
  namespace: aurora
spec:
  replicas: 1
  selector:
    matchLabels:
      app: aurora-shell
  template:
    metadata:
      labels:
        app: aurora-shell
    spec:
      containers:
      - name: aurora-shell
        image: $REGISTRY_NAME.azurecr.io/aurora-shell:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "250m"
---
apiVersion: v1
kind: Service
metadata:
  name: aurora-shell
  namespace: aurora
spec:
  type: LoadBalancer
  selector:
    app: aurora-shell
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
EOF

# Get LoadBalancer IP
kubectl get service aurora-shell -n aurora
```

### 4.4 Verification
```bash
# Check all deployments
kubectl get all -n aurora
kubectl get all -n platform
kubectl get all -n argocd

# Check logs
kubectl logs -n aurora -l app=aurora-shell
kubectl logs -n platform -l app=backstage

# Access applications
echo "Aurora Frontend: http://$(kubectl get service aurora-shell -n aurora -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo "API Gateway: $(az webapp list --resource-group nebula-student-rg --query "[?name=='aurora-api'].hostNames[0]" -o tsv)"
```

### 4.5 Documentation for Phase 4
**Record:**
- Container registry push logs
- App Service deployment logs
- All kubectl get outputs
- Application access URLs
- Final cost summary
- All three projects running simultaneously

---

## Phase 5: Cleanup & Cost Summary

### 5.1 Cleanup Script
```bash
#!/bin/bash
# cleanup-all.sh

echo "Starting cleanup..."

# Delete Kubernetes namespaces
kubectl delete namespace platform
kubectl delete namespace argocd
kubectl delete namespace aurora

# Delete resource groups
az group delete --name nebula-student-rg --yes

# Delete App Service
az appservice plan delete \
  --name aurora-plan \
  --resource-group nebula-student-rg \
  --yes

# Delete Container Registry
az acr delete \
  --name aurorastudent \
  --resource-group nebula-student-rg \
  --yes

echo "Cleanup complete!"
```

### 5.2 Final Cost Report
```bash
#!/bin/bash
# cost-summary.sh

echo "=== Azure Student Account Cost Summary ==="
az costmanagement query \
  --scope "/subscriptions/$(az account show -q id -o tsv)" \
  --timeframe "MonthToDate" \
  --granularity "Daily" \
  --metrics "PreTaxCost"

echo ""
echo "=== Resource Summary ==="
az group list --query "[] | [?resourceGroup=='nebula-student-rg']"

echo ""
echo "=== Expected Monthly Cost ==="
echo "- AKS (B2s, 1 node): ~$30-40/month"
echo "- SQL Database (Free): $0"
echo "- Redis (Basic): ~$15-20/month"
echo "- Storage: ~$1-2/month"
echo "- App Service (F1): $0"
echo "- Container Registry (Basic): ~$5/month"
echo "TOTAL ESTIMATED: $51-67/month (within student budget)"
```

---

## Video Recording Guide

### Recording Checklist
- [ ] Set screen resolution to 1920x1080
- [ ] Use OBS Studio or similar
- [ ] Record each phase separately
- [ ] Include terminal output clearly
- [ ] Zoom in on important sections
- [ ] Add chapter markers

### Recommended Recording Sections
1. **Intro (2 min)**
   - Overview of all three projects
   - Architecture diagram
   - Deployment strategy

2. **Phase 1: Nebula (15 min)**
   - Azure setup
   - Terraform init/plan
   - Resource creation
   - kubectl verification

3. **Phase 2: Genesis (12 min)**
   - Helm installation
   - ArgoCD deployment
   - Backstage setup
   - Application sync

4. **Phase 3: Aurora (15 min)**
   - Container build
   - App Service deploy
   - Frontend to AKS
   - All systems running

5. **Outro (3 min)**
   - Cost summary
   - Cleanup process
   - Key takeaways

---

## Documentation Files to Create

### README Files to Generate
- [ ] DEPLOYMENT_VIDEO_NOTES.md
- [ ] COST_ANALYSIS.md
- [ ] TROUBLESHOOTING.md
- [ ] SCREENSHOTS_GUIDE.md
- [ ] ARCHITECTURE_OVERVIEW.md

### Artifacts to Collect
- [ ] All terraform outputs
- [ ] All kubectl commands & outputs
- [ ] Azure CLI commands
- [ ] Cost management reports
- [ ] Screenshots from Azure Portal
- [ ] Screenshots from each application dashboard

---

## Common Issues & Solutions

### Issue 1: Free Tier Quota Exceeded
**Solution:**
```bash
# Check quotas
az vm list-usage --location eastus

# Request quota increase
az support ticket create \
  --ticket-name "Free Tier Quota Increase" \
  --description "Student account needs higher quota"
```

### Issue 2: Pod Scheduling Fails
**Solution:**
```bash
# Check node resources
kubectl describe nodes

# Scale down existing deployments
kubectl scale deployment argocd-server --replicas 0 -n argocd

# Try deploying Aurora again
```

### Issue 3: LoadBalancer IP Pending
**Solution:**
```bash
# Patch service to NodePort temporarily
kubectl patch svc aurora-shell -n aurora -p '{"spec": {"type": "NodePort"}}'

# Access via port forward
kubectl port-forward service/aurora-shell 3000:80 -n aurora
```

---

## Success Metrics

- [ ] Terraform deploys all resources without errors
- [ ] AKS cluster has at least 1 healthy node
- [ ] ArgoCD shows all applications in sync
- [ ] Backstage portal is accessible
- [ ] Aurora frontend loads without errors
- [ ] All services show in kubectl
- [ ] Total monthly cost stays under $100
- [ ] Complete video recording with audio
- [ ] All documentation is comprehensive

---

## Commands Quick Reference

```bash
# Azure Login
az login
az account set --subscription "ID"

# Terraform
terraform init
terraform plan
terraform apply
terraform output
terraform destroy

# Kubernetes
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces
kubectl apply -f deployment.yaml
kubectl logs -n NAMESPACE -l app=APP_NAME

# ArgoCD
argocd login SERVER
argocd app list
argocd app sync APP_NAME

# Azure Services
az group list
az aks get-credentials --name CLUSTER --resource-group RG
az webapp list --resource-group RG
az acr list --resource-group RG
```

---

**Last Updated:** 2026-05-06  
**Author:** Deployment Guide Generator  
**Version:** 1.0.0
