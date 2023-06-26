data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_security_group" "public" {
  name        = "public"  
  description = "allows public traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from home office"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["68.228.97.89/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public"
  }
}

resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.public.id]
  key_name                    = "demo"
  associate_public_ip_address = true

  tags = {
    Name = "public"
  }
}


resource "aws_security_group" "private" {
  name        = "private"  
  description = "allows private traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private"
  }
}

resource "aws_instance" "private" {
  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private[0].id
  vpc_security_group_ids      = [aws_security_group.private.id]
  key_name                    = "demo"
   

  tags = {
    Name = "private"
  }
}

output "public_ip_address"{
   value = aws_instance.public.public_ip 
}