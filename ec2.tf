# Crear la instancia EC2
resource "aws_instance" "builder" {
  ami                    = "ami-0f0417a092a64beee"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.deployer.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "docker-builder"
  }

  # Provisión remota en la instancia EC2
  provisioner "remote-exec" {
  inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo yum install git -y",
      "sudo service docker start",
      "$(aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.my_repo.repository_url})",
      "git clone https://${var.GITHUB_USER}:${var.GITHUB_TOKEN}@github.com/${var.GITHUB_WORKSPACE}/${var.GITHUB_REPOSITORY} && cd ${var.GITHUB_REPOSITORY}/",
      "sudo docker build -t my-docker-repo .",
      "sudo docker tag my-docker-repo:latest ${aws_ecr_repository.my_repo.repository_url}:latest",
      "sudo docker push ${aws_ecr_repository.my_repo.repository_url}:latest"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.key.private_key_pem
      host        = self.public_ip
    }
  }
}