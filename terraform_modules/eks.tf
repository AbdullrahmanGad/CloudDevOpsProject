# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  # Cluster endpoint access
  # Public isn't supposed to be reachable so the default will be false
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = true

  # EKS Managed Node Group
  eks_managed_node_groups = {
    main = {
      name           = "main-node-group"
      instance_types = var.node_instance_types
      
      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size
      disk_size    = var.node_disk_size
      
      ami_type = "AL2023_x86_64_STANDARD"

      # Add ECR access policy
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }

      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      tags = {
        Environment = var.environment
        Project     = "ivolve-project"
      }
    }
  }

  # Cluster addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  tags = {
    Environment = var.environment
    Project     = "ivolve-project"
    ManagedBy   = "Terraform"
  }
}

