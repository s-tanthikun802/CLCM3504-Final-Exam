output "aws_instance_public_dns" {
  value = aws_instance.website_instance.public_dns
}