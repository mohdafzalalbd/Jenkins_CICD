output "instance_id" {
  value       = aws_instance.main.id
  description = "Instance ID"
}

output "public_ip" {
  value       = aws_instance.main.public_ip
  description = "Public IP address"
}

output "private_ip" {
  value       = aws_instance.main.private_ip
  description = "Private IP address"
}

output "public_dns" {
  value       = aws_instance.main.public_dns
  description = "Public DNS name"
}
