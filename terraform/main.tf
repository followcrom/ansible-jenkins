provider "aws" {
  region = "eu-west-1"
}

# Security Group
resource "aws_security_group" "terraform-nsg" {
  name        = "terraform-nsg"
  description = "Combined SG for SSH, Port 3000, and HTTP access"

  # SSH Access from a specific IP
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # cidr_blocks = ["your-public-ip/32"]
    cidr_blocks = ["0.0.0.0/32"]
  }

  # get your public IP address:
  # `curl ifconfig.me`

  # Access to Port 3000 from anywhere
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "richard-terraform-2" {
  ami                         = var.app_ami_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "tech257"
  vpc_security_group_ids      = [aws_security_group.terraform-nsg.id] # the nsg created above
  tags = {
    Name = "richard-terraform-2"
  }
}
