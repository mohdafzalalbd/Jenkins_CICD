variable "instance_name" {
  type        = string
  description = "Name of the instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t3.medium"
}

variable "ami_id" {
  type        = string
  description = "AMI ID"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security group IDs"
  default     = []
}

variable "user_data" {
  type        = string
  description = "User data script (base64 encoded)"
  default     = ""
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

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate public IP address"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags for instance"
  default     = {}
}
