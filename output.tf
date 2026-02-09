# VPC Outputs
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the VPC"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr
  description = "CIDR block of the VPC"
}

output "public_subnet_id" {
  value       = module.vpc.public_subnet_id
  description = "ID of the public subnet"
}

output "private_subnet_id" {
  value       = module.vpc.private_subnet_id
  description = "ID of the private subnet"
}

# Jenkins Instance Outputs
output "jenkins_instance_id" {
  value       = module.jenkins_instance.instance_id
  description = "Instance ID of the Jenkins server"
}

output "jenkins_public_ip" {
  value       = module.jenkins_instance.public_ip
  description = "Public IP address of the Jenkins server"
}

output "jenkins_private_ip" {
  value       = module.jenkins_instance.private_ip
  description = "Private IP address of the Jenkins server"
}

output "jenkins_url" {
  value       = "http://${module.jenkins_instance.public_ip}:8080"
  description = "URL to access Jenkins server"
}

# Security Group Outputs
output "jenkins_security_group_id" {
  value       = module.jenkins_sg.id
  description = "ID of the Jenkins security group"
}

output "jenkins_security_group_name" {
  value       = module.jenkins_sg.name
  description = "Name of the Jenkins security group"
}

# Connection Information
output "ssh_command" {
  value       = "ssh -i /path/to/key.pem ec2-user@${module.jenkins_instance.public_ip}"
  description = "SSH command to connect to the Jenkins server"
}

output "jenkins_initial_admin_password_location" {
  value       = "/var/lib/jenkins/secrets/initialAdminPassword"
  description = "Location of Jenkins initial admin password on the server"
}
