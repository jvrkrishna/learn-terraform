########### Create ec2 instance in terraform ###############
resource "aws_instance" "web" {
  ami           = data.aws_ami.example.id
  instance_type = "t3.small"
  vpc_security_group_ids = ["aws_security_group.sg.id"]

  tags = {
    Name = "Rks"
  }

########### provisioner in terraform ############
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "centos"
      password = "DevOps321"
      host     = self.public_ip
    }
    inline = [
      "sudo labauto ansible",
      "ansible-pull -i localhost, -U https://github.com/jvrkrishna/roboshopp-ansible roboshop.yml -e role_name=${var.name}"
    ]
  }
}

############### create route 53 record terraform ####################
resource "aws_route53_record" "www" {
  zone_id = "Z0858447245XTBTK7DY06"
  name    = "${var.name}-dev"
  type    = "A"
  ttl     = 30
  records = [aws_instance.web.private_ip]
}

############## create aws_ami in terraform ######################
data "aws_ami" "example" {
  most_recent      = true
  name_regex       = "Centos-8-DevOps-Practice"
  owners           = ["973714476881"]
}


################# create security group in terraform #####################
resource "aws_security_group" "sg" {
  name        = var.name
  description = "Allow TLS inbound traffic"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}

variable "name" {}