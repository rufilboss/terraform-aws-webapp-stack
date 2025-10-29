variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Domain name for RStudio Connect"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 LTS"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Ubuntu 22.04 LTS in us-east-1
}

variable "rstudio_license" {
  description = "RStudio Connect license key"
  type        = string
  sensitive   = true
}

variable "admin_user" {
  description = "Admin username for RStudio Connect"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Admin password for RStudio Connect"
  type        = string
  sensitive   = true
}