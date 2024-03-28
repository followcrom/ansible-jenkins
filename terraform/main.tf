provider "aws" {
  region = "eu-west-1"
}


resource "aws_instance" "richard-terraform-2" {
  ami                         = var.app_ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.terraform_nsg.id]
  tags = {
    Name = "richard-terraform-2"
  }
}
