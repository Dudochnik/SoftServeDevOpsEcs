packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variables {
  aws_access_key = null
  aws_secret_key = null
  aws_ecr_address = null
}

locals {
  html_source = "${path.root}/src/"
}

source "docker" "test" {
  image = "ubuntu:18.04"
  commit = true
  changes = [
    "CMD [\"-D\", \"FOREGROUND\"]",
    "ENTRYPOINT [\"apachectl\"]"
  ]
}

build {
  sources = ["source.docker.test"]

  provisioner "shell" {
    inline = ["mkdir /var/www", "mkdir /var/www/html", "apt-get update && apt-get install -y apache2"]
  }

  provisioner "file" {
    source = local.html_source
    destination = "/var/www/html"
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "${var.aws_ecr_address}/terraform"
      tags = ["latest"]
    }

    post-processor "docker-push" {
      ecr_login = true
      aws_access_key = var.aws_access_key
      aws_secret_key = var.aws_secret_key
      login_server = "https://${var.aws_ecr_address}/"
    }
  }
}



