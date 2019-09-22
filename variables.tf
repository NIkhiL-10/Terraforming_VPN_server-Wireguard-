variable "public_key" {
  default = "~/.ssh/wireguard.pub"
}

variable "private_key" {
  default = "~/.ssh/wireguard.pem"
}

variable "ami" {
  default = "ami-04763b3055de4860b"
}

variable "ansible_user" {
  default = "ubuntu"
}