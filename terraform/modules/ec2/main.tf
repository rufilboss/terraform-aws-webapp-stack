resource "aws_security_group" "rstudio_sg" {
  vpc_id      = var.vpc_id
  name        = "rstudio-sg"
  description = "Allow HTTP/HTTPS from ALB and SSH"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
}

resource "aws_instance" "rstudio" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  user_data     = data.template_file.user_data.rendered
  vpc_security_group_ids = [aws_security_group.rstudio_sg.id]

  tags = { Name = "rstudio-connect" }
}