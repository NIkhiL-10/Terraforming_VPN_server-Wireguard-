provider "aws" {
  profile = "default"
  region = "us-east-1"
}

resource "aws_key_pair" "wireguard" {
  key_name = "wireguard"
  public_key = "${file(var.public_key)}"
}

resource "aws_security_group" "wireguard" {
  name        = "wireguard"
  description = "Security group for instance to allow wireguard connections"

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
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

  tags = {
    Purpose = "wireguard"
  }
}

resource "aws_instance" "wireguard" {
  ami = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.wireguard.key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.wireguard.id}"
  ]
  associate_public_ip_address = true

  connection {
    host = "${self.public_ip}"
    private_key = "${file(var.private_key)}"
    user        = "${var.ansible_user}"
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
        >wireguard.ini
	    echo "[wireguard]" | tee -a wireguard.ini;
	    echo ${aws_instance.wireguard.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key} | tee -a wireguard.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
	    ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i wireguard.ini -e @ansible/defaults/main.yml -e @ansible/vars/main.yml ansible/main.yml
    EOT
  }

  tags = {
    Purpose = "wireguard"
  }

}


