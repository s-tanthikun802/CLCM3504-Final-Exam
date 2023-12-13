variable "region" {
  default     = "us-east-1"
  description = "AWS region where the EC2 instance will be launched."
}

variable "ami_id" {
  default     = "ami-01bc990364452ab3e" # Amazon Linux 2023 AMI
  description = "AMI ID of the EC2 instance."
}

variable "instance_type" {
  default     = "t2.micro"
  description = "EC2 instance type."
}