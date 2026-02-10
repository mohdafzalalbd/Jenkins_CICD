#!/bin/bash
set -e

# Update system packages
apt-get update
apt-get upgrade -y

# Install Java
apt-get install -y openjdk-11-jdk

# Add Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Install Jenkins
apt-get update
apt-get install -y jenkins

# Start and enable Jenkins
systemctl start jenkins
systemctl enable jenkins

# Install Git (commonly used with Jenkins)
apt-get install -y git

# Install Docker (optional, useful for CI/CD)
apt-get install -y docker.io
usermod -aG docker jenkins
systemctl start docker
systemctl enable docker

# Output Jenkins initial admin password location
echo "Jenkins installation complete!"
echo "Access Jenkins at http://$(hostname -I | awk '{print $1}'):8080"
echo "Initial admin password is at: /var/lib/jenkins/secrets/initialAdminPassword"

# Log completion
echo "$(date): Jenkins setup completed" >> /var/log/jenkins-init.log
