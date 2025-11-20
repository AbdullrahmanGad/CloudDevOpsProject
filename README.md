# EKS CI/CD Pipeline with Terraform, GitHub Actions & ArgoCD
A complete end-to-end DevOps project demonstrating containerization, infrastructure as code, and GitOps practices for deploying applications on Amazon EKS.

## Overview
This project implements a fully automated CI/CD pipeline that:

- Provisions AWS infrastructure using Terraform
- Builds and scans Docker images with automatic versioning
- Push the image to ECR
- Sends notifications via Telegram
- Deploys applications to EKS using ArgoCD
# Architecture  
![Untitled Diagram drawio](https://github.com/user-attachments/assets/2bc6441a-78f5-4d4e-950f-d1350bc941c8)

## Features
- **Infrastructure as Code**: Complete AWS infrastructure provisioned with Terraform
- **Automated CI Pipeline**: GitHub Actions for building, scanning, and pushing images
- **GitOps Deployment**: ArgoCD for continuous deployment
- **Security Scanning**: Trivy integration for container vulnerability scanning
- **Version Management**: Automated image version increment
- **Notifications**: Telegram integration for pipeline status updates

## Structure

```bash
.
├── terraform_modules/
├── kubernetes_manifests/            # Kubernetes deployment files
├── argocd_manifests/            # ArgoCD deployment files
├── .github/
│   └── workflows/                   # CI pipeline
├── app/
├── VERSION.txt               # Image version tracker
└── README.md
```
## Technologies Used

- **Cloud Provider**: AWS (EKS, ECR, VPC)
- **Infrastructure**: Terraform
- **Containerization**: Docker
- **Orchestration**: Kubernetes (EKS)
- **CI/CD**: GitHub Actions
- **GitOps**: ArgoCD
- **Security**: Trivy
- **Notifications**: Telegram Bot

## Steps

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <project-directory>
```

### 2. Containerize the Application
- Dockerfile

<img width="677" height="352" alt="image" src="https://github.com/user-attachments/assets/96fcbd77-5a04-46c2-8453-850ac7ec4718" />

- build to test the image.
```bash
docker build -t flask-app-test:latest .
docker run -p 8080:8080 flask-app-test:latest
```

### 3. Create Kubernetes Manifests

Create deployment and service manifests in `kubernetes-manifests/`:

- `deployment.yaml`
  ![8654](https://github.com/user-attachments/assets/2d4478e6-99d2-42ef-8b63-8f1baa0f4416)
- `service.yaml`
  <img width="531" height="383" alt="image" src="https://github.com/user-attachments/assets/6576112c-ba0f-4a83-8844-d8787e20b66e" />

- `namespace.yaml`
  <img width="496" height="221" alt="image" src="https://github.com/user-attachments/assets/b4702a0a-495c-40fe-8198-fd133697bfb5" />

### 4. Infrastructure Provisioning with Terraform

#### Network Module

- VPC with public and private subnets
- Internet Gateway (IGW)
- Route tables

#### EKS Module

- EKS cluster with managed node groups
- IAM roles and policies
- Cluster add-ons (CoreDNS, kube-proxy, VPC-CNI)
- IRSA (IAM Roles for Service Accounts)

#### ECR Module

- Private container registry

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

![eks-ecr-created](https://github.com/user-attachments/assets/b9e33d95-5bd9-491f-9d7b-1a3aa63c5fcd)

- EKS Created:
  ![eks](https://github.com/user-attachments/assets/ec91f9d2-064a-47f2-b3c7-ff44f9f09e91)
- Nodes are Running:  
  ![nodes](https://github.com/user-attachments/assets/56537b7c-0002-43a4-838a-7e9ef8331dbd)
- ECR Created:
  ![sadas](https://github.com/user-attachments/assets/8efbaa29-5821-4f79-a987-85297b8753bf)

### 5. Configure AWS Credentials

```bash
aws configure
```

Update kubeconfig for EKS access:

```bash
aws eks update-kubeconfig --name ivolve-cluster --region us-east-1
```
- Test Kubectl:
  ![podsrunning](https://github.com/user-attachments/assets/28d1fc56-a97f-4554-b40b-727c4d772d87)

### 6. Configure GitHub Actions

Add these secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID`
- `AWS_ACCOUNT_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_CHAT_ID`

### 7. CI Pipeline Stages

The GitHub Actions pipeline automatically:

1. **Read Version**: Reads current image version from `VERSION`
2. **Increment Version**: Bumps the semantic version
3. **Update Version File**: Commits new version back to repository
4. **Build Image**: Creates Docker image with new version tag
5. **Scan Image**: Runs Trivy security scan
6. **Push to ECR**: Uploads image to Amazon ECR
7. **Clean Up**: Removes local Docker images
8. **Update Manifests**: Updates Kubernetes manifests with new image version
9. **Commit Manifests**: Pushes updated manifests to repository
10. **Notify**: Sends Telegram notification with pipeline status

  ![pipelinesuccess](https://github.com/user-attachments/assets/f320c7e4-5e4d-4b11-a3f9-1b55318c177c)
  ![asda](https://github.com/user-attachments/assets/14d57d77-4f2f-4886-aaf9-3a70ed7adc89)

### 8. Deploy ArgoCD

Install ArgoCD in your EKS cluster:

### 9. Configure ArgoCD Application

- Apply the configuration:

```bash
kubectl apply -f argocd-app.yaml
kubectl apply -f argocd-service-lb.yaml
```

- Create an ArgoCD application pointing to your kubernetes-manifests:
  ![31](https://github.com/user-attachments/assets/5ee8d9a5-0268-4c22-97b2-6a62013136fd)
- ECR secrets:
  ![argocd14](https://github.com/user-attachments/assets/02d38625-3f56-4c65-a3dd-4588cfa98bde)
- LoadBalancer Service:
  ![link](https://github.com/user-attachments/assets/a1b2853a-587d-42ce-97b2-8f56a0577d9a)
- Verify The deployment Through UI.
  ![argocd15](https://github.com/user-attachments/assets/ebfc1d0e-4047-442c-aa39-2cb0551557c2)
  ![argocd16](https://github.com/user-attachments/assets/b76b2d31-6b46-4f54-9fea-ef4057a07d3d)



### Monitoring & Verification

- Check pipeline status:
- Verify pods in EKS
```bash
kubectl get pods -n ivolve
```
- Check service endpoint
```bash
kubectl get svc -n ivolve
```
- Access the loadbalancer URL:
  ![app](https://github.com/user-attachments/assets/11135c81-dca4-4821-880b-d0587513141b)

## 🔐 Security Features

- **Trivy Scanning**: Automated vulnerability detection
- **IAM Roles**: Fine-grained access control with IRSA
- **Private Subnets**: Worker nodes isolated from internet
- **ECR Image Scanning**: Container registry security
- **Network Policies**: Kubernetes network segmentation
