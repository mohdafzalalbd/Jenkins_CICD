# Jenkins CI/CD Infrastructure as Code (Terraform)

This project automates the provisioning of a complete Jenkins CI/CD infrastructure on AWS using Terraform. It creates a VPC with public/private subnets, security groups, and an EC2 instance with Jenkins pre-installed.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [File Explanations](#file-explanations)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Outputs](#outputs)
- [Post-Deployment](#post-deployment)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

---

## Overview

This Terraform project provides Infrastructure as Code (IaC) to deploy:

- **AWS VPC** - Virtual Private Cloud with custom CIDR blocks
- **Public Subnet** - For Jenkins server with internet access
- **Private Subnet** - For future internal resources
- **Internet Gateway** - For public subnet to reach the internet
- **Security Groups** - Firewall rules for SSH and Jenkins access
- **EC2 Instance** - Ubuntu-based server with Jenkins pre-installed
- **Route Tables** - Network routing configuration

### What Gets Created

```
┌─────────────────────────────────────┐
│          AWS VPC (10.0.0.0/16)      │
├─────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐ │
│  │   Public     │  │   Private    │ │
│  │  Subnet      │  │   Subnet     │ │
│  │(10.0.1.0/24)│  │(10.0.2.0/24) │ │
│  └──────┬───────┘  └──────────────┘ │
│         │                            │
│      ┌──▼──────────────────────┐    │
│      │   Jenkins EC2 Instance  │    │
│      │   - t3.medium           │    │
│      │   - Ubuntu 20.04        │    │
│      │   - Port 8080 (Jenkins) │    │
│      │   - Port 22 (SSH)       │    │
│      └─────────────────────────┘    │
└─────────────────────────────────────┘
```

---

## Prerequisites

Before you begin, ensure you have the following installed and configured:

### 1. **Terraform** (v1.0 or higher)
   - Download: https://www.terraform.io/downloads.html
   - Install Terraform on your system
   - Verify installation:
     ```bash
     terraform --version
     ```

### 2. **AWS Account**
   - Active AWS account with billing enabled
   - Permissions to create VPC, EC2, and Security Groups
   - Note: This project uses ap-south-1 (Mumbai) region by default

### 3. **AWS CLI** (Optional but recommended)
   - Download: https://aws.amazon.com/cli/
   - Configure your AWS credentials:
     ```bash
     aws configure
     # Enter your AWS Access Key ID
     # Enter your AWS Secret Access Key
     # Enter your default region (ap-south-1 recommended)
     # Enter your default output format (e.g., json)
     ```

### 4. **Git** (Optional but recommended)
   - For version control of your infrastructure

### 5. **SSH Key Pair** (For accessing Jenkins server)
   - Create an EC2 key pair in AWS console or CLI:
     ```bash
     aws ec2 create-key-pair --key-name jenkins-key --region ap-south-1 \
       --query 'KeyMaterial' --output text > jenkins-key.pem
     chmod 400 jenkins-key.pem
     ```

---

## Project Structure

```
Jenkins_CICD/
├── main.tf                    # Main orchestration file - defines all modules
├── provider.tf               # AWS provider configuration
├── variable.tf               # Input variables with defaults
├── output.tf                 # Output values (IPs, URLs, IDs)
├── backend.tf                # Remote state configuration (optional, commented)
├── module.tf                 # Module reference documentation (for reference only)
├── README.md                 # Complete user guide (this file)
├── KNOWLEDGE.md              # Comprehensive knowledge base and project journey
├── jenkins-init.sh           # Bootstrap script for Jenkins installation
├── .terraform/               # Terraform working directory (auto-created)
├── terraform.tfstate         # State file (auto-created, tracks resources)
├── terraform.tfstate.backup  # Backup of state file
│
├── vpc/                      # VPC Module
│   ├── main.tf              # VPC, subnets, IGW, route tables
│   ├── variables.tf         # Input variables for VPC module
│   └── outputs.tf           # VPC output values
│
├── security_group/          # Security Group Module
│   ├── main.tf              # Security group rules
│   ├── variables.tf         # Input variables for SG module
│   └── outputs.tf           # SG output values
│
└── ec2/                     # EC2 Module
    ├── main.tf              # EC2 instance configuration
    ├── variables.tf         # Input variables for EC2 module
    └── outputs.tf           # EC2 output values

```

---

## Getting Started

### Step 1: Clone or Download the Project

```bash
# If using Git
git clone <repository-url>
cd Jenkins_CICD

# Or manually download and extract the project folder
```

### Step 2: Navigate to Project Directory

```bash
cd Jenkins_CICD
```

### Step 3: Review the Configuration

Before deploying, check the default values in `variable.tf`:

```bash
cat variable.tf
```

---

## File Explanations

### **provider.tf** - AWS Provider Setup
This file configures the AWS provider and Terraform version requirements.

```hcl
terraform {
  required_version = ">= 1.0"              # Terraform 1.0 or newer
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"                  # AWS provider version
    }
  }
}

provider "aws" {
  region = var.aws_region                 # Uses variable from variable.tf
  
  default_tags {                          # Tags applied to ALL resources
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "Jenkins-CICD"
    }
  }
}
```

**Key Concepts:**
- `required_version`: Ensures Terraform compatibility
- `required_providers`: Specifies AWS provider version
- `default_tags`: Automatically tags all resources for organization

---

### **variable.tf** - Input Variables
Variables are like parameters for your infrastructure. They have defaults but can be overridden.

**Key Variables:**

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | ap-south-1 | AWS region for resources (Mumbai) |
| `environment` | string | Production | Environment name |
| `vpc_cidr` | string | 10.0.0.0/16 | VPC network range |
| `public_subnet_cidr` | string | 10.0.1.0/24 | Public subnet range |
| `private_subnet_cidr` | string | 10.0.2.0/24 | Private subnet range |
| `instance_type` | string | t3.medium | EC2 instance size |
| `jenkins_port` | number | 8080 | Jenkins web interface port |
| `ssh_port` | number | 22 | SSH access port |
| `allowed_ssh_cidr` | list(string) | 0.0.0.0/0 | CIDR blocks for SSH (CHANGE THIS!) |

**How to Use Variables:**
- **Using defaults**: Just run `terraform apply` (uses all defaults)
- **Override via CLI**: `terraform apply -var="instance_type=t3.large"`
- **Using terraform.tfvars**: Create a file with your values

---

### **main.tf** - Main Configuration
This is the orchestration file that combines modules and creates the infrastructure.

**Sections:**

1. **Data Sources**: Query AWS for existing resources
   ```hcl
   data "aws_availability_zones" "available" {
     state = "available"
   }
   ```

2. **Module Calls**: Instantiate modules with variables
   ```hcl
   module "vpc" {
     source = "./vpc"
     vpc_cidr = var.vpc_cidr
     # ... other variables
   }
   ```

**Module Dependencies:**
- `vpc` module: Creates networking (called first)
- `jenkins_sg` module: Depends on VPC ID
- `jenkins_instance` module: Depends on VPC and Security Group

---

### **output.tf** - Output Values
Outputs display important information after deployment (IPs, URLs, IDs).

**Available Outputs:**

| Output | Description | Example |
|--------|-------------|---------|
| `vpc_id` | VPC identifier | vpc-12345678 |
| `vpc_cidr` | VPC CIDR block | 10.0.0.0/16 |
| `public_subnet_id` | Public subnet ID | subnet-12345678 |
| `private_subnet_id` | Private subnet ID | subnet-87654321 |
| `jenkins_instance_id` | EC2 instance ID | i-0123456789abcdef0 |
| `jenkins_public_ip` | Jenkins server IP | 54.123.45.67 |
| `jenkins_private_ip` | Instance private IP | 10.0.1.42 |
| `jenkins_url` | Direct access URL | http://54.123.45.67:8080 |
| `jenkins_availability_zone` | Instance AZ | us-east-1a |
| `jenkins_security_group_id` | Security group ID | sg-0123456789abcdef0 |
| `jenkins_security_group_name` | Security group name | jenkins-security-group |
| `ssh_command` | SSH connection string | ssh -i key.pem ec2-user@IP |
| `resource_tags` | Applied resource tags | {Environment: Production, ...} |

**View outputs after deployment:**
```bash
terraform output                          # Show all outputs
terraform output jenkins_url              # Show specific output
terraform output -json                    # JSON format
```

---

### **Modules** - Reusable Components

#### **VPC Module** (`vpc/`)
Creates networking infrastructure.

**Files:**
- `main.tf`: AWS resources (VPC, subnets, IGW)
- `variables.tf`: Input variables
- `outputs.tf`: Output values

**Resources Created:**
- AWS VPC with custom CIDR (DNS hostnames and DNS support enabled)
- Public subnet (with auto-assign public IP on launch)
- Private subnet
- Internet Gateway
- Route table for public subnet (routes 0.0.0.0/0 to IGW)
- Route table for private subnet
- NAT Gateway option (configurable via `enable_nat_gateway` variable)

---

#### **Security Group Module** (`security_group/`)
Manages firewall rules.

**Files:**
- `main.tf`: Security group and rules
- `variables.tf`: Input for rules
- `outputs.tf`: Security group ID and name

**Features:**
- Dynamic ingress rules from list
- Dynamic egress rules from list
- Supports any port/protocol

**Example Ingress Rule:**
```hcl
{
  from_port   = 8080          # Start port
  to_port     = 8080          # End port
  protocol    = "tcp"         # Protocol type
  cidr_blocks = ["0.0.0.0/0"] # Allowed sources
  description = "Jenkins web"
}
```

---

#### **EC2 Module** (`ec2/`)
Configures the Jenkins server instance.

**Files:**
- `main.tf`: EC2 instance configuration
- `variables.tf`: Input variables
- `outputs.tf`: Instance details

**Instance Features:**
- Runs user data script (jenkins-init.sh)
- Encrypted root volume
- CloudWatch monitoring enabled
- Public IP association

---

### **jenkins-init.sh** - Bootstrap Script
This script runs automatically when the instance starts, installing Jenkins and dependencies.

**What It Does:**
1. Updates system packages
2. Installs Java 11 (Jenkins requirement)
3. Adds Jenkins repository
4. Installs Jenkins
5. Starts and enables Jenkins service
6. Installs Git (useful for CI/CD)
7. Installs Docker (optional container support)

**Script Output:**
```bash
Jenkins installation complete!
Access Jenkins at http://10.0.1.100:8080
Initial admin password is at: /var/lib/jenkins/secrets/initialAdminPassword
```

---

## Configuration

### **Option 1: Using Defaults**
Simply deploy without changes (quickest way):
```bash
terraform init
terraform plan
terraform apply
```

### **Option 2: Using terraform.tfvars** (Recommended)
Create a file to override variables:

```bash
cat > terraform.tfvars << EOF
aws_region             = "ap-south-1"
environment            = "Production"
instance_type          = "t3.medium"
allowed_ssh_cidr       = ["YOUR_IP/32"]   # Change to your IP!
allowed_jenkins_cidr   = ["0.0.0.0/0"]
EOF
```

**Common Values:**

```hcl
# For a large setup
instance_type        = "t3.large"
root_volume_size     = 50

# Restrict SSH access (recommended)
allowed_ssh_cidr     = ["203.0.113.45/32"]  # Your public IP

# Different region
aws_region           = "eu-west-1"  # Or other regions (default: ap-south-1)

# Staging environment
environment          = "Staging"
```

### **Option 3: Command Line Variables**
```bash
terraform apply \
  -var="instance_type=t3.large" \
  -var="environment=Development"
```

---

## Deployment

### **Step 1: Initialize Terraform**
Downloads provider plugins and prepares working directory.

```bash
terraform init
```

**Output:**
```
Initializing the backend...
Initializing modules...
- vpc in ./vpc
- jenkins_sg in ./security_group
- jenkins_instance in ./ec2
```

### **Step 2: Plan Deployment**
Shows what will be created (dry-run).

```bash
# Save plan to file (recommended for production)
terraform plan -out=tfplan
```

**Review the output for:**
- Resources being created/modified/destroyed
- Variable values being used
- Number of resources (should be ~12-15)
- All details match your intentions

**Why save the plan?**
- Ensures the exact same changes are applied
- Prevents changes between plan and apply
- Required best practice for production

### **Step 3: Apply Configuration**
Creates actual resources on AWS using the saved plan.

```bash
# Apply the saved plan (recommended)
terraform apply tfplan

# Or apply without a saved plan (not recommended)
# terraform apply
```

**When prompted:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

**Wait for completion** (typically 5-10 minutes):
```
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

jenkins_instance_id = "i-0123456789abcdef0"
jenkins_public_ip = "54.123.45.67"
jenkins_url = "http://54.123.45.67:8080"
```

---

## Outputs

After successful deployment, Terraform displays important information:

```bash
# View all outputs
terraform output

# View specific output
terraform output jenkins_url

# Get Jenkins IP for SSH
terraform output jenkins_public_ip

# View Jenkins URL
terraform output jenkins_url
```

**Example Output:**
```
jenkins_instance_id = "i-0c1234567890abcde"
jenkins_private_ip = "10.0.1.42"
jenkins_public_ip = "54.123.45.67"
jenkins_url = "http://54.123.45.67:8080"
jenkins_security_group_id = "sg-0123456789abcdef0"
ssh_command = "ssh -i /path/to/key.pem ec2-user@54.123.45.67"
vpc_id = "vpc-0123456789abcdef0"
vpc_cidr = "10.0.0.0/16"
```

---

## Post-Deployment

### **1. Access Jenkins Server**

#### Via SSH (for troubleshooting):
```bash
# Get SSH command from outputs
terraform output ssh_command

# Or manually
ssh -i jenkins-key.pem ec2-user@<public-ip>
```

#### Via Web Browser:
```bash
# Get Jenkins URL
terraform output jenkins_url

# Or manually
# Visit: http://<public-ip>:8080
```

### **2. Unlock Jenkins (First Time Setup)**

Jenkins requires an initial admin password on first access.

**Get the password:**
```bash
# SSH into the instance
ssh -i jenkins-key.pem ec2-user@<public-ip>

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

**First Time Setup Steps:**
1. Open `http://<public-ip>:8080` in browser
2. Paste the initial password
3. Click "Continue"
4. Choose "Install suggested plugins" or "Select plugins to install"
5. Create first admin user
6. Configure Jenkins URL
7. Start using Jenkins!

### **3. Verify Installation**

Check if Jenkins is running:
```bash
# SSH into instance
ssh -i jenkins-key.pem ec2-user@<public-ip>

# Check Jenkins service
sudo systemctl status jenkins

# View Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log
```

### **4. Install Additional Plugins** (Optional)

Common useful plugins:
- **Pipeline**: For CI/CD pipeline scripts
- **GitHub Integration**: To connect to GitHub repositories
- **Docker**: To use Docker in builds
- **AWS CodePipeline**: For AWS integration

---

## Security Considerations

⚠️ **IMPORTANT**: The default configuration allows access from anywhere (`0.0.0.0/0`). This is NOT secure for production!

### **1. Restrict SSH Access**

Edit `terraform.tfvars`:
```hcl
allowed_ssh_cidr = ["YOUR_PUBLIC_IP/32"]
```

**Find your IP:**
```bash
curl https://checkip.amazonaws.com
```

### **2. Restrict Jenkins Access**

For production, restrict Jenkins to your organization:
```hcl
allowed_jenkins_cidr = ["203.0.113.0/24"]  # Your office/VPN CIDR
```

### **3. Use Strong Jenkins Admin Password**

During initial setup, create a strong password:
- Minimum 12 characters
- Mix of uppercase, lowercase, numbers, symbols

### **4. Enable Jenkins Security Features**

After setup:
1. Go to Jenkins → Manage Jenkins → Configure Global Security
2. Enable "Prevent Cross Site Request Forgery (CSRF)"
3. Enable "Markup Formatter"
4. Configure user permissions

### **5. Backup Jenkins Configuration**

```bash
# SSH into instance
ssh -i jenkins-key.pem ec2-user@<public-ip>

# Backup Jenkins directory
sudo tar -czf jenkins-backup.tar.gz /var/lib/jenkins/

# Download to local machine
scp -i jenkins-key.pem ec2-user@<public-ip>:/home/ec2-user/jenkins-backup.tar.gz ./
```

### **6. Update Instance Type for Production**

For production workloads, use larger instance:
```hcl
instance_type = "t3.large"
```

---

## Troubleshooting

### **Problem 1: terraform init fails**

**Error:**
```
Error: error getting credentials from shell
```

**Solution:**
```bash
# Configure AWS credentials
aws configure

# Verify credentials
aws sts get-caller-identity
```

### **Problem 2: Cannot connect to Jenkins server**

**Checklist:**
1. Verify instance is running:
   ```bash
   terraform output jenkins_instance_id
   aws ec2 describe-instances --instance-ids <instance-id>
   ```

2. Check security group allows port 8080:
   ```bash
   terraform output jenkins_security_group_id
   aws ec2 describe-security-groups --group-ids <sg-id>
   ```

3. Wait 5-10 minutes for Jenkins installation to complete

4. SSH into instance to check logs:
   ```bash
   ssh -i jenkins-key.pem ec2-user@<public-ip>
   sudo tail -f /var/log/jenkins/jenkins.log
   ```

### **Problem 3: terraform plan shows many changes**

**Cause:** AMI ID may have changed or region is different.

**Solution:**
```bash
# Check current variable values
terraform plan -out=tfplan

# Update AMI ID if needed
terraform var="ami_id=ami-0c55b159cbfafe1f0"
```

### **Problem 4: Insufficient EC2 capacity**

**Error:**
```
InsufficientCapacity in the requested Availability Zone
```

**Solution:**
1. Change availability zone in `terraform.tfvars`:
   ```hcl
   availability_zone = "ap-south-1b"
   ```

2. Or change instance type:
   ```hcl
   instance_type = "t3.small"
   ```

### **Problem 5: SSH connection denied**

**Possible causes:**
1. Wrong key pair - ensure using correct key:
   ```bash
   ssh -i correct-key.pem ec2-user@<public-ip>
   ```

2. Security group doesn't allow SSH - verify:
   ```bash
   terraform output jenkins_security_group_id
   ```

---

## Cleanup

### **Destroy All Resources**

When you're done and want to remove all AWS resources:

```bash
# Preview what will be destroyed
terraform plan -destroy

# Actually destroy resources
terraform destroy
```

**When prompted:**
```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure.

  Enter a value: yes
```

**Verification:**
```bash
# Check no resources were created
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=Jenkins-CICD"
```

### **Keep State but Destroy Resources** (Advanced)

If you want to manually manage some resources:
```bash
terraform destroy -auto-approve
```

---

## Next Steps

After successful deployment:

1. **Review Project Documentation**
   - Read KNOWLEDGE.md for complete project history
   - Understand architecture decisions
   - Review security considerations

2. **Configure Jenkins**
   - Set up authentication (LDAP, GitHub, etc.)
   - Configure build agents/workers
   - Set up webhooks for repositories

3. **Create Your First Pipeline**
   - Create a simple pipeline job
   - Connect to a Git repository
   - Set up automated builds

4. **Add Plugins**
   - Install pipeline plugins
   - Add cloud integration plugins
   - Install monitoring plugins

5. **Set Up Backups**
   - Regular Jenkins configuration backups
   - Use Jenkins backup/restore plugins

6. **Monitor Infrastructure**
   - Set up CloudWatch alarms
   - Monitor EC2 instance metrics
   - Track AWS costs

---

## Common Commands Reference

```bash
# Initialize
terraform init

# Planning & Validation
terraform plan                           # Show what will change
terraform validate                       # Check syntax
terraform fmt                            # Format HCL files

# Deployment
terraform apply                          # Create/update resources
terraform apply -auto-approve           # Apply without confirmation

# Management
terraform state list                     # List managed resources
terraform state show module.vpc          # Show resource details
terraform output                         # Display outputs
terraform output -json                   # JSON format

# Cleanup
terraform destroy                        # Delete all resources
terraform destroy -auto-approve         # Delete without confirmation
```

---

## Project Files Guide

### Documentation Files
- **README.md** - Complete user guide (you are here)
- **KNOWLEDGE.md** - Comprehensive knowledge base with development journey, architecture decisions, and lessons learned

### Main Configuration Files
- **main.tf** - Orchestration file with module calls and data sources
- **provider.tf** - AWS provider setup and Terraform version constraints
- **variable.tf** - Input variables with defaults and descriptions
- **output.tf** - Output values for displaying important information
- **backend.tf** - Remote state configuration (optional, currently commented)
- **module.tf** - Module reference documentation (use main.tf for actual definitions)

### Bootstrap Script
- **jenkins-init.sh** - Automatic Jenkins installation script

### Module Directories
- **vpc/** - VPC networking module
- **security_group/** - Security group rules module
- **ec2/** - EC2 instance configuration module

---

## Additional Resources

- **Terraform Documentation**: https://www.terraform.io/docs/
- **AWS Provider Documentation**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Jenkins Documentation**: https://www.jenkins.io/doc/
- **AWS EC2 Documentation**: https://docs.aws.amazon.com/ec2/
- **GitHub Repository**: https://github.com/mohdafzalalbd/Jenkins_CICD

---

## Support & Questions

If you encounter issues:

1. **Check Terraform logs**:
   ```bash
   export TF_LOG=DEBUG
   terraform plan
   ```

2. **Validate configuration**:
   ```bash
   terraform validate
   terraform fmt -recursive
   ```

3. **Review AWS console**: Check EC2, VPC, and Security Groups in AWS console

4. **Check Jenkins logs** (after SSH):
   ```bash
   sudo tail -100 /var/log/jenkins/jenkins.log
   ```

---

## License

This infrastructure code is provided as-is for educational and production use.

---

## Author Notes

This project demonstrates:
- ✅ Terraform best practices (modular, parameterized)
- ✅ AWS VPC and networking
- ✅ EC2 instance management
- ✅ Security group configuration
- ✅ Infrastructure automation
- ✅ IaC principles

Perfect for learning DevOps and cloud infrastructure!

---

## Project Statistics

- **Total Files**: 18
- **Total Lines of Code**: ~600
- **Terraform Modules**: 3
- **AWS Resources**: ~12-15
- **Total Variables**: 14
- **Total Outputs**: 13
- **Documentation Sections**: 20+

## Important Notes

⚠️ **Security**: Default configuration allows public access (0.0.0.0/0). This is NOT suitable for production. Always restrict access using CIDR blocks in `terraform.tfvars`.

💡 **Best Practice**: Always use `terraform plan -out=tfplan` before applying to ensure reproducible deployments.

📝 **Tip**: Check KNOWLEDGE.md for detailed project journey, architecture decisions, and troubleshooting strategies.

---

**Last Updated**: February 9, 2026
**Terraform Version**: >= 1.0
**AWS Provider Version**: ~> 5.0
**Documentation Version**: 2.0 (Updated with all corrections)
