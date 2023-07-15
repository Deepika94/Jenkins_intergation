# Creating the VPC 

resource "aws_vpc" "myvpc" {
  cidr_block = "15.0.0.0/16"
  tags = {
    name = "Demo-vpc"
  }
}

# creating the 3 subnet in the 3 avilablity zone

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "15.0.1.0/24"
  availability_zone ="${var.az_zone1}"
}

resource "aws_subnet" "subnet2" {
vpc_id = aws_vpc.myvpc.id
cidr_block = "15.0.2.0/24"
availability_zone = "${var.az_zone2}"
}

resource "aws_subnet" "subnet3" {
vpc_id = aws_vpc.myvpc.id
cidr_block = "15.0.3.0/24"
availability_zone = "${var.az_zone3}"
}

# Creating the Internet Gateway and attaching to the VPC
resource "aws_internet_gateway" "ig" {
vpc_id = aws_vpc.myvpc.id
tags = {
  name = "Demo-igw"
}
}

# Creting the public route and ading the internet gateway to it 
resource "aws_route_table" "public_rt" {
vpc_id = aws_vpc.myvpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.ig.id
}
tags = {
  name ="demo route"
}
}

# Creating the Route table association 
resource "aws_route_table_association" "public_association1" {
route_table_id = aws_route_table.public_rt.id
subnet_id = aws_subnet.subnet1.id
}

resource "aws_route_table_association" "public_association2" {
route_table_id = aws_route_table.public_rt.id
subnet_id = aws_subnet.subnet2.id
}

resource "aws_route_table_association" "public_association3" {
route_table_id = aws_route_table.public_rt.id
subnet_id = aws_subnet.subnet3.id
}
# Create the security groups
resource "aws_security_group" "server1_sg" {
name = "Access_sg"
vpc_id = aws_vpc.myvpc.id
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

}
egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create the EC2 Instance 
resource "aws_instance" "server1" {
ami = "ami-053b0d53c279acc90"
vpc_security_group_ids = [aws_security_group.server1_sg.id]
instance_type = "t2.micro"
subnet_id = aws_subnet.subnet1.id
user_data = <<-EOF
#! /bin/bash
sudo apt-get update -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

EOF
tags = {
 name = "demo-server1"
}
}

resource "aws_instance" "server2" {
ami = "ami-053b0d53c279acc90"
instance_type = "t2.micro"
vpc_security_group_ids = [aws_security_group.server1_sg.id]
subnet_id = aws_subnet.subnet2.id
user_data = <<-EOF
#! /bin/bash
sudo apt-get update -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

EOF
tags = { 
 name = "demo-server2"
}
}