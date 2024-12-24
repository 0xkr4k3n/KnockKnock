provider "aws"{
    region = "eu-central-1"
}

resource "aws_security_group" "port_knocking_sec_group" {
  name = "port_knocking_security_group"
  description = "Security group for port knocking"
    ingress {
        description = "Allow ping"
        from_port = -1
        to_port = -1
        protocol = "ICMP"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
        description = "Allow Knocking ports"
        from_port = "1234"
        to_port = "9999"
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        description = "Allow SSH after knocking"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}

resource "aws_instance" "port_knocking_instance" {
  ami = "ami-084f072343a80d2eb"
  instance_type = "t2.micro"
  key_name = "port_knocking_kp"
    security_groups = [aws_security_group.port_knocking_sec_group.name]
      tags = {
    Name = "PortKnockingTest"
  }
}
output "instance_ip" {
  value = aws_instance.port_knocking_instance.public_ip
}