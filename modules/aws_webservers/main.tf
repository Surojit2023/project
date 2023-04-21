terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }

  required_version = ">=0.14"
}
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "terraform_remote_state" "private_subnet" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "projectf"                  // Bucket from where to GET Terraform State
    key    = "network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                 // Region where bucket created
  }
}

data "terraform_remote_state" "public_subnet" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "projectf"                  // Bucket from where to GET Terraform State
    key    = "network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                 // Region where bucket created
  }
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
}

# Adding SSH  key to instance
resource "aws_key_pair" "project2" {
  key_name   = var.prefix
  public_key = file("${var.prefix}.pub")
}

#security Group
resource "aws_security_group" "projects" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.private_subnet.outputs.vpc_id

  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-EBS"
    }
  )
}



# Create another EBS volume
resource "aws_ebs_volume" "web_ebs" {
  count             = var.env == "prod" ? 1 : 0
  availability_zone = data.aws_availability_zones.available.names[1]
  size              = 40

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-EBS"
    }
  )
}

resource "aws_instance" "projects" {

  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.project2.key_name
  security_groups             = [aws_security_group.projects.id]
  subnet_id                   = data.terraform_remote_state.public_subnet.outputs.subnet_id[0]
  associate_public_ip_address = false
  #    user_data  = file("${path.module}/install_httpd.sh")
  user_data = <<-EOF
                  #!/bin/bash
                  echo "Hello Students" > project.txt
                  yum -y update
                  yum -y install httpd
                  echo "<h1>Welcome to project!"  >  /var/www/html/index.html
                  sudo systemctl start httpd
                  sudo systemctl enable httpd
               EOF

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix1}-Amazon-Linux"
    }
  )
}

resource "aws_instance" "acs73026" {

  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.project2.key_name
  security_groups             = [aws_security_group.projects.id]
  subnet_id                   = data.terraform_remote_state.public_subnet.outputs.subnet_id[1]
  associate_public_ip_address = false
  #    user_data  = file("${path.module}/install_httpd.sh")
  user_data = <<-EOF
                  #!/bin/bash
                  echo "Hello Students" > project.txt
                  yum -y update
                  yum -y install httpd
                  echo "<h1>Welcome to project!"  >  /var/www/html/index.html
                  sudo systemctl start httpd
                  sudo systemctl enable httpd
               EOF

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix2}-Amazon-Linux"
    }
  )
}

resource "aws_instance" "acs73028" {

  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.project2.key_name
  security_groups             = [aws_security_group.projects.id]
  subnet_id                   = data.terraform_remote_state.public_subnet.outputs.subnet_id[1]
  associate_public_ip_address = true
  #    user_data  = file("${path.module}/install_httpd.sh")
  user_data = <<-EOF
                  #!/bin/bash
                  echo "Hello Students" > project.txt
                  yum -y update
                  yum -y install httpd
                  echo "<h1>Welcome to project!" >  /var/www/html/index.html
                  sudo systemctl start httpd
                  sudo systemctl enable httpd
               EOF

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix3}-Amazon-Linux"
    }
  )
}

#security Group
resource "aws_security_group" "projectes" {
  name        = "allow_http_ssh_bastion"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.public_subnet.outputs.vpc_id

  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix3}-SGS"
    }
  )
}

# Bastion IP
resource "aws_eip" "static_eip" {
  instance = aws_instance.projects.id
  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix3}-eip"
    }
  )
}
