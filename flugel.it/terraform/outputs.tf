output "application_url" {
  description = "Public URI address of the python service EC2"
  value       = "http://${aws_instance.ec2_manager_service.public_dns}:8000"
}