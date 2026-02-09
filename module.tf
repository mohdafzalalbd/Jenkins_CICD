module "vpc" {
  source = "./vpc"
  
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  
  tags = merge(var.tags, {
    Name = "main-vpc"
  })
}

module "jenkins_instance" {
  source = "./ec2"
  
  instance_name        = var.instance_name
  instance_type        = var.instance_type
  ami_id               = var.ami_id
  availability_zone    = var.availability_zone
  
  subnet_id            = module.vpc.public_subnet_id
  vpc_security_group_ids = [module.jenkins_sg.id]
  
  user_data = base64encode(file("${path.module}/jenkins-init.sh"))
  
  root_volume_size     = var.root_volume_size
  root_volume_type     = var.root_volume_type
  
  tags = merge(var.tags, {
    Name        = var.instance_name
    Application = "Jenkins"
  })
}

module "jenkins_sg" {
  source = "./security_group"
  
  name        = "jenkins-security-group"
  description = "Security group for Jenkins server"
  vpc_id      = module.vpc.vpc_id
  
  ingress_rules = [
    {
      from_port   = var.ssh_port
      to_port     = var.ssh_port
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_cidr
      description = "SSH access"
    },
    {
      from_port   = var.jenkins_port
      to_port     = var.jenkins_port
      protocol    = "tcp"
      cidr_blocks = var.allowed_jenkins_cidr
      description = "Jenkins web interface"
    }
  ]
  
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
  
  tags = merge(var.tags, {
    Name = "jenkins-sg"
  })
}