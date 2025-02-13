provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "testvpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "testvpc"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.testvpc.id
  cidr_block              = "10.0.0.0/26"
  map_public_ip_on_launch = true
  tags = {
    Name = "publicsubnet"
  }

}

resource "aws_internet_gateway" "testigw" {
  vpc_id = aws_vpc.testvpc.id
  tags = {
    Name = "testigw"
  }

}

# resource "aws_internet_gateway_attachment" "testigwattach" {
#   internet_gateway_id = aws_internet_gateway.testigw.id
#   vpc_id              = aws_vpc.testvpc.id
# }

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.testvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.testigw.id
  }
  tags = {
    Name = "publicrt"
  }


}

resource "aws_route_table_association" "rtassociate" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.publicrt.id

}

# Create EC2 Instance

resource "aws_instance" "testinstance" {
  ami             = "ami-085ad6ae776d8f09c"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.publicsubnet.id
  security_groups = [aws_security_group.testsg.id]
  key_name        = aws_key_pair.testkey.key_name
  user_data       = file("${path.module}/user_data.sh")


}

resource "aws_security_group" "testsg" {
  name        = "testsg"
  vpc_id      = aws_vpc.testvpc.id
  description = "This will allow ssh to the instance"
  tags = {
    Name = "testsg"
  }

}

resource "aws_security_group_rule" "testsgrule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.testsg.id
}

resource "aws_key_pair" "testkey" {
  key_name   = "terraform-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBYf2XzZ90AuEnffj6MBUkRWyMmVKblhyFgyO+X9nU34 sumitkamble@Sumits-MacBook-Air.local"

}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.testinstance.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.testinstance.private_ip
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.testinstance.id
}

