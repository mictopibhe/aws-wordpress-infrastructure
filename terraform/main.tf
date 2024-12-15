variable "artifact_id" {
  description = "AMI id"
}

terraform {
  required_providers {
  aws = {
    source = "hashicorp/aws"
    version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

resource "aws_instance" "example" {
  ami           = "var.artifact_id" 
  instance_type = "t2.micro"             

  
  tags = {
    Name = "DevOps-terraform-HW"
  }
}