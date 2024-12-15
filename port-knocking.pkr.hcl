variable "aws_region" {
  default = "eu-central-1"
}

source "amazon-ebs" "port_knocking_ami" {
  region           = var.aws_region
  source_ami       = "ami-0745b7d4092315796"
  instance_type    = "t2.micro"
  ssh_username     = "ubuntu"               
  ami_name         = "port-knocking-ssh-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.port_knocking_ami"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo apt install -y openssh-server",
      "sudo systemctl enable ssh",
      "sudo systemctl start ssh",
      "sudo docker pull kraken636/port-knocking",
      "sudo docker run -d -p 1234:1234 -p 5678:5678 -p 3456:3456 kraken636/port-knocking"
    ]
  }
}

