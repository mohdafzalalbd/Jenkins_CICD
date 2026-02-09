variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "Production"
}

# VPC Variables
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for private subnet"
  default     = "10.0.2.0/24"
}

# EC2 Instance Variables
variable "instance_name" {
  type        = string
  description = "Name of the Jenkins instance"
  default     = "jenkins-server"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the instance (Ubuntu 20.04 LTS)"
  default     = "ami-0c55b159cbfafe1f0"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the instance"
  default     = "us-east-1a"
}

variable "root_volume_size" {
  type        = number
  description = "Root volume size in GB"
  default     = 30
}

variable "root_volume_type" {
  type        = string
  description = "Root volume type"
  default     = "gp3"
}

# Security Group Variables
variable "jenkins_port" {
  type        = number
  description = "Jenkins web interface port"
  default     = 8080
}

variable "ssh_port" {
  type        = number
  description = "SSH port"
  default     = 22
}

variable "allowed_ssh_cidr" {
  type        = list(string)
  description = "CIDR blocks allowed for SSH access"
  default     = ["0.0.0.0/0"]
  sensitive   = false
}

variable "allowed_jenkins_cidr" {
  type        = list(string)
  description = "CIDR blocks allowed for Jenkins access"
  default     = ["0.0.0.0/0"]
  sensitive   = false
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Project     = "Jenkins-CICD"
  }
}
