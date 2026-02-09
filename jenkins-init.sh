#!/bin/bash
set -e

# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Java
sudo apt-get install -y openjdk-11-jdk

# Add Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Install Jenkins
sudo apt-get update
sudo apt-get install -y jenkins

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Git (commonly used with Jenkins)
sudo apt-get install -y git

# Install Docker (optional, useful for CI/CD)
sudo apt-get install -y docker.io
sudo usermod -aG docker jenkins
sudo systemctl start docker
sudo systemctl enable docker

# Output Jenkins initial admin password location
echo "Jenkins installation complete!"
echo "Access Jenkins at http://$(hostname -I | awk '{print $1}'):8080"
echo "Initial admin password is at: /var/lib/jenkins/secrets/initialAdminPassword"
