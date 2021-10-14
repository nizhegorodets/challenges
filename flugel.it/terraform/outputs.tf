output "instance_public_uri" {
  description = "Public URI address of the EC2 instance"
  value       = "http://${aws_instance.ec2_manager_service.public_ip}"
}