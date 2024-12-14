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
    "source.amazon-ebs.ubuntu-lts"
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
    script = "./docker.sh"
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}