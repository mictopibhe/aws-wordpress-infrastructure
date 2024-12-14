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

variable "db_user" {
  type    = string
  default = "default_user"
}

variable "db_password" {
  type    = string
  default = "default_password"
}

variable "db_name" {
  type    = string
  default = "default_db"
}

variable "db_root_password" {
  type    = string
  default = "default_root_password"
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
      "echo 'DB_USER={{user `db_user`}}' > /tmp/db_user.env",
      "echo 'DB_PASSWORD={{user `db_password`}}' > /tmp/db_password.env",
      "echo 'DB_NAME={{user `db_name`}}' > /tmp/db_name.env",
      "echo 'DB_ROOT_PASSWORD={{user `db_root_password`}}' > /tmp/db_root_password.env"
    ]
  }

  provisioner "shell" {
    script = "./docker.sh"
  }
}