# Configure AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Get latest Amazon Linux 2 ARM AMI
data "aws_ami" "amazon_linux_2_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-arm64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create spot instance request
resource "aws_spot_instance_request" "worker" {
  ami                    = data.aws_ami.amazon_linux_2_arm.id
  instance_type          = "c8g.4xlarge"
  spot_type              = "one-time"
  wait_for_fulfillment   = true
  spot_price            = "0.0638"  # Set your maximum spot price

  # IAM role if needed
  # iam_instance_profile = "your-instance-profile"

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name              = "MyKeyPair-us-east-1"  # Replace with your key pair

  user_data = <<-EOF
              #!/bin/bash
              echo "Starting initialization..."
              cd /home/ec2-user
              aws s3 cp s3://your-bucket/run.sh .  # If script is in S3
              git clone https://github.com/habanoz/tokenize_s3.git
              cd tokenize_s3
              chmod +x run.sh
              ./run.sh
              # Signal completion to terminate instance
              aws ec2 terminate-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id)
              EOF

  tags = {
    Name = "SpotWorker"
  }
}

# Security group for SSH access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

# Output the instance ID
output "instance_id" {
  value = aws_spot_instance_request.worker.spot_instance_id
}

output "public_ip" {
  value = aws_spot_instance_request.worker.public_ip
}