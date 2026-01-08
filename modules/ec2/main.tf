data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update system
    yum update -y

    # Install required packages
    yum install -y bind-utils curl wget

    # Configure DNS resolution for cdn.mytest.com
    # Add custom DNS entry to /etc/hosts pointing to the internal ALB
    echo "# Custom DNS entry for CDN" >> /etc/hosts
    echo "${var.alb_dns_name} ${var.cdn_fqdn}" >> /etc/hosts

    # Install CloudWatch agent for monitoring
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
    rpm -U ./amazon-cloudwatch-agent.rpm

    # Log the configuration
    echo "EC2 instance configured successfully" > /var/log/user-data.log
    echo "CDN FQDN: ${var.cdn_fqdn}" >> /var/log/user-data.log
    echo "ALB DNS: ${var.alb_dns_name}" >> /var/log/user-data.log

    # Test DNS resolution
    nslookup ${var.cdn_fqdn} >> /var/log/user-data.log 2>&1 || true

  EOF
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.ec2_security_group]
  iam_instance_profile   = var.iam_instance_profile

  user_data = base64encode(local.user_data)

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2"
  }
}
