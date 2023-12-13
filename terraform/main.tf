provider "aws" {
  region = var.region
}

resource "aws_security_group" "ec2_sg" {
  name = "group_4_project_sg"
  description = "Allow HTTP inbound traffic"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0    # All
    to_port     = 0    # All
    protocol    = "-1" # All
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "website_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = "Group4KeyPair"
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "group4_clcm3504_project"
  }
}

