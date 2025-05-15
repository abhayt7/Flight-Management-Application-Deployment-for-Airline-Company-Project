provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "sg_k8s_master" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_k8s_node1" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2379
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_jenkins" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k8s_master" {
  ami                    = "ami-0f1490dceaf192473"
  instance_type           = "t2.medium"
  subnet_id              = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  key_name               = "awskey"
  security_groups        = [aws_security_group.sg_k8s_master.id]
  tags                   = { Name = "K8sMaster" }

  user_data = <<-EOF
    #!/bin/bash
    sudo useradd ansible -m -s /bin/bash -p $(openssl passwd -1 admin@123)
    echo 'ansible ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config
    sudo systemctl restart ssh
  EOF
}

resource "aws_instance" "k8s_node1" {
  ami                    = "ami-0f1490dceaf192473"
  instance_type           = "t2.medium"
  subnet_id              = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  key_name               = "awskey"
  security_groups        = [aws_security_group.sg_k8s_node1.id]
  tags                   = { Name = "K8sNode1" }

  user_data = <<-EOF
    #!/bin/bash
    sudo useradd ansible -m -s /bin/bash -p $(openssl passwd -1 admin@123)
    echo 'ansible ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config
    sudo systemctl restart ssh
  EOF
}

resource "aws_instance" "jenkins" {
  ami                    = "ami-0453ec754f44f9a4a"
  instance_type           = "t2.medium"
  subnet_id              = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  key_name               = "awskey"
  security_groups        = [aws_security_group.sg_jenkins.id]
  root_block_device {
    volume_size = 22
  }
  tags                   = { Name = "jenkins1" }

  user_data = <<-EOF
    #!/bin/bash
    sudo useradd ansible -m -s /bin/bash -p $(openssl passwd -1 admin@123)
    echo 'ansible ALL=(ALL:ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
  EOF
}
