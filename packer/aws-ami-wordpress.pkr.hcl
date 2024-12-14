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
  DB_USER = getenv("DB_USER", "fallback_value")
  DB_PASSWORD = getenv("DB_PASSWORD", "fallback_value")
  DB_NAME = getenv("DB_NAME", "fallback_value")
  DB_ROOT_PASSWORD = getenv("DB_ROOT_PASSWORD", "fallback_value")
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
      "export DB_USER=${local.DB_USER}",
      "export DB_PASSWORD=${local.DB_PASSWORD}",
      "export DB_NAME=${local.DB_NAME}",
      "export DB_ROOT_PASSWORD=${local.DB_ROOT_PASSWORD}"
    ]
  }

  provisioner "shell" {
    script = "./docker.sh"
  }
}