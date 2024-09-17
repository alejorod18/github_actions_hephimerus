resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.GITHUB_REPOSITORY}-key"
  public_key = tls_private_key.key.public_key_openssh
}
