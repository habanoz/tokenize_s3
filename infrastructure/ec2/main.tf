# Configure AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role_policy" "s3_access" {
  name = "s3_access"
  role = aws_iam_role.spot_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::your-bucket/*",  # Replace with your bucket name
          "arn:aws:s3:::your-bucket"     # Replace with your bucket name
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:TerminateInstances"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# Create instance profile
resource "aws_iam_instance_profile" "spot_instance_profile" {
  name = "spot_instance_profile"
  role = aws_iam_role.spot_instance_role.name
}

resource "aws_iam_role" "spot_instance_role" {
  name = "spot_instance_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create spot instance request
resource "aws_spot_instance_request" "worker" {
  ami                    = "ami-0bdf149a42243bde8"
  instance_type          = "c8g.4xlarge"
  spot_type              = "one-time"
  wait_for_fulfillment   = true
  spot_price            = "0.0638"  # Set your maximum spot price
  
  subnet_id             = data.aws_subnet.selected.id
  # IAM role if needed
  iam_instance_profile = aws_iam_instance_profile.spot_instance_profile.name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name              = "MyKeyPair-us-east-1"

  user_data = <<-EOF
              #!/bin/bash
              echo "Starting initialization..."
              cd /home/ec2-user
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

data "aws_subnet" "selected" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-east-1b"
}

# get default vpc
data "aws_vpc" "default" {
  default = true
}

# Security group for SSH access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id

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