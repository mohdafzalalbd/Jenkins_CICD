# Backend configuration (optional - uncomment when ready to use S3 remote state)
# Requires:
# - S3 bucket: my-terraform-state-bucket
# - DynamoDB table: terraform-locks with LockID primary key
#
# terraform {
#   backend "s3" {
#     bucket         = "my-terraform-state-bucket"
#     key            = "jenkins-cicd/terraform.tfstate"
#     region         = "ap-south-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }
#
# For now, using local state (terraform.tfstate in project root)

