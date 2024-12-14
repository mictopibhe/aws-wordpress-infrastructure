variable "db_user" {
  type    = string
  default = wordpress
}
variable "db_password" {
  type    = string
  default = wordpress
}
variable "db_name" {
  type    = string
  default = wordpress
}
variable "db_root_password" {
  type    = string
  default = wordpress
}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[-TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  region        = "eu-central-1"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  instance_type = "t2.micro"
  ssh_username = "ubuntu"
  ami_name      = "wordpress-ami-${local.timestamp}"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source      = "docker-compose.yml"
    destination = "/home/ubuntu/docker-compose.yml"
  }

  provisioner "file" {
    source      = "nginx.conf"
    destination = "/home/ubuntu/nginx.conf"
  }

  provisioner "shell" {
    inline = [
      "export DB_USER=${var.db_user}",
      "export DB_PASSWORD=${var.db_password}",
      "export DB_NAME=${var.db_name}",
      "export DB_ROOT_PASSWORD=${var.db_root_password}"
    ]
  }

  provisioner "shell" {
    script = "./docker.sh"
  }
}