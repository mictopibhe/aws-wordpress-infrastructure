variable "db_user" {
  description = "The database user"
}
variable "db_password" {
  description = "The database password"
}
variable "db_name" {
  description = "The database name"
}
variable "db_root_password" {
  description = "The database root password"
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
    source      = "./packer/docker-compose.yml"
    destination = "/home/ubuntu/docker-compose.yml"
  }

  provisioner "file" {
    source      = "./packer/nginx.conf"
    destination = "/home/ubuntu/nginx.conf"
  }

  provisioner "shell" {
    inline = [
      "export DB_USER=\"${var.db_user}\"",
      "export DB_PASSWORD=\"${var.db_password}\"",
      "export DB_NAME=\"${var.db_name}\"",
      "export DB_ROOT_PASSWORD=\"${var.db_root_password}\"",
      "chmod +x ./packer/docker.sh",
      "./packer/docker.sh"
    ]
  }

  post-processor "manifest" {
    output = "manifest.json"
    strip_path = true
}

}