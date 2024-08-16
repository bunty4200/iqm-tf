provider "aws" {
  region = "ap-south-1"
  access_key = "AKIAXYKJVWZ4UDDJR24H"
  secret_key = "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"
}

resource "aws_instance" "ansible" { 
    ami = "ami-0c2af51e265bd5e0e"
    instance_type = "t2.small"
    key_name = "iqm"
    //security_groups = [ "demo-sg" ]
    vpc_security_group_ids = [ aws_security_group.demo-sg.id ]
    subnet_id = aws_subnet.dpp-public-subnet-01.id
    tags = {
      Name = "ansible-server"
    }
}

resource "aws_instance" "Jenkins_master_and_slave" { 
    ami = "ami-0c2af51e265bd5e0e"
    instance_type = "t2.medium"
    key_name = "iqm"
    //security_groups = [ "demo-sg" ]
    vpc_security_group_ids = [ aws_security_group.demo-sg.id ]
    subnet_id = aws_subnet.dpp-public-subnet-01.id
for_each = toset(["Jenkins-master", "maven-slave"])
    tags = {
      Name = "${each.key}"
    }
}


resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH ACCESS"
  vpc_id = aws_vpc.dpp-vpc.id

  ingress {
    description      = "SSH ACCESS"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH ACCESS"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-port"
  }
}


resource "aws_vpc" "dpp-vpc" {
    cidr_block = "10.1.0.0/16"
    tags = {
        Name = "dpp-vpc"
    }
  
}

resource "aws_subnet" "dpp-public-subnet-01" {
  vpc_id     = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"

  tags = {
    Name = "dpp-public-subnet-01"
  }
}

resource "aws_subnet" "dpp-public-subnet-02" {
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1b"

   tags = {
    Name = "dpp-public-subnet-02"
  }
  
}


resource "aws_internet_gateway" "dpp-igw" {
  vpc_id = aws_vpc.dpp-vpc.id
  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "dpp-public-rt" {
  vpc_id = aws_vpc.dpp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpp-igw.id
  }
}

resource "aws_route_table_association" "dpp-rta-public-subnet-01" {
  subnet_id      = aws_subnet.dpp-public-subnet-01.id
  route_table_id = aws_route_table.dpp-public-rt.id
}

resource "aws_route_table_association" "dpp-rta-public-subnet-02" {
  subnet_id     = aws_subnet.dpp-public-subnet-02.id
  route_table_id = aws_route_table.dpp-public-rt.id
}