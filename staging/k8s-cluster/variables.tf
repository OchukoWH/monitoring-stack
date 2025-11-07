variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "stack_name" {
  description = "Name of the monitoring stack"
  type        = string
  default     = "monitoring-stack"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "instance_type" {
  description = "EC2 instance type for monitoring nodes"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "monitoring-keypair"
}
