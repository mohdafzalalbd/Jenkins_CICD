variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for private subnet"
}

variable "tags" {
  type        = map(string)
  description = "Tags for VPC resources"
  default     = {}
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway for private subnet internet access"
  default     = false
}
