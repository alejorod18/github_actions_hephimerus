resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "${pathexpand("~/.ssh/key.pem")}"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = tls_private_key.key.public_key_openssh
  filename        = "${pathexpand("~/.ssh/key.pem.pub")}"
  file_permission = "0644"
}

resource "aws_key_pair" "deployer" {
  key_name   = "key"
  public_key = tls_private_key.key.public_key_openssh
}
