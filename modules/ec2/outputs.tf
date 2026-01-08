output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "private_ip" {
  description = "EC2 instance private IP"
  value       = aws_instance.main.private_ip
}

output "availability_zone" {
  description = "EC2 instance availability zone"
  value       = aws_instance.main.availability_zone
}

output "ami_id" {
  description = "AMI ID used for the instance"
  value       = aws_instance.main.ami
}
