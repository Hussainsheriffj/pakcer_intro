packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
    type    = string
    default = "packer-linux-aws-vpc-selected"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-northeast-3"
  # since we don't have a default vpc we are giving vpc_id
  vpc_id = "vpc-0996d36a86586aee0"
  #   vpc_filter {
  #     filters {
  #         "cidr": "/16"
  #     }
  #   }
  source_ami_filter {
    filters = {
      name = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      #ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220609 we made few tweaks to this
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  #below we are using shell provisioner
#   provisioner "shell" {
#     environment_vars = [
#       "FOO=hello world",
#     ]
#     inline = [
#       "echo Installing Redis",
#       "sleep 30",
#       "sudo apt-get update",
#       "sudo apt-get install -y redis-server",
#       "echo \"FOO is $FOO\" > example.txt",
#     ]
#   }

  #below we are using ansible provisioner
  provisioner "ansible"{
    playbook_file = "./playbook.yml"
  }

}
