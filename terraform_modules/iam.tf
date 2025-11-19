# IAM roles are automatically created by the EKS module
# But here you can add custom IAM policies here if needed

# for me i need Custom policy for pods to access S3 bucket:
# also need IAM policy for github-actions to reach the ecr registry.

resource "aws_iam_policy" "pod_s3_access" {
  count = var.enable_s3_access ? 1 : 0
  
  name        = "${var.cluster_name}-pod-s3-access"
  description = "Allow pods to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = "ivolve-project"
  }
}

# IAM User for GitHub Actions
resource "aws_iam_user" "github_actions" {
  name = "${var.cluster_name}-github-actions"

  tags = {
    Name        = "${var.cluster_name}-github-actions"
    Environment = var.environment
    Project     = "ivolve-project"
    ManagedBy   = "Terraform"
    Purpose     = "CI/CD"
  }
}

# IAM Policy for ECR Push
resource "aws_iam_policy" "github_actions_ecr" {
  name        = "${var.cluster_name}-github-actions-ecr"
  description = "Allow GitHub Actions to push images to ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = aws_ecr_repository.ivolve_project.arn
      }
    ]
  })

  tags = {
    Name        = "${var.cluster_name}-github-actions-ecr"
    Environment = var.environment
    Project     = "ivolve-project"
  }
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "github_actions_ecr" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}

# Create access key for GitHub Actions
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

# Outputs for GitHub Secrets
output "github_actions_access_key_id" {
  description = "Access Key ID for GitHub Actions (Add to GitHub Secrets)"
  value       = aws_iam_access_key.github_actions.id
  sensitive   = true
}

output "github_actions_secret_access_key" {
  description = "Secret Access Key for GitHub Actions (Add to GitHub Secrets)"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
}

output "github_secrets_setup" {
  description = "Instructions for setting up GitHub Secrets"
  value = <<-EOT
    Add these secrets to your GitHub repository:
    
    AWS_ACCESS_KEY_ID: ${aws_iam_access_key.github_actions.id}
    AWS_SECRET_ACCESS_KEY: <run: terraform output -raw github_actions_secret_access_key>
    AWS_ACCOUNT_ID: ${data.aws_caller_identity.current.account_id}
    AWS_REGION: ${var.aws_region}
  EOT
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
