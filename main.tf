provider "aws" {
  region = "ap-south-1"
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


# 1. Generate a new private key
resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Create the AWS Key Pair
resource "aws_key_pair" "key" {
  key_name   = "key"
  public_key = tls_private_key.jenkins_key.public_key_openssh
}

# 3. Save the private key locally
resource "local_sensitive_file" "key" {
  content         = tls_private_key.jenkins_key.private_key_pem
  filename        = "${path.module}/key.pem"
  file_permission = "0600"
}

# 4. Define the Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH, HTTP, and Jenkins traffic"

  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For better security, replace with your IP: "x.x.x.x/32"
  }

  # Jenkins Web UI (Port 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Standard HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rules (Allow instance to download packages)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Update the Instance Resource
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t3.small"
  key_name               = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id] # Add this line

  tags = {
    Name = "Jenkins-Server"
	}

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              dnf update -y

              # 2. Install Docker (dnf replaces amazon-linux-extras)
              dnf install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user

              # 3. Install Jenkins with the correct 2023 GPG key
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              
              dnf install java-17-amazon-corretto -y
              dnf install jenkins -y
              
              systemctl start jenkins
              systemctl enable jenkins
              EOF
}

output "jenkins_public_ip" {
  description = "The public IP address of the Jenkins server"
  value       = aws_instance.jenkins.public_ip
}
