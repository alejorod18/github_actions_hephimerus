provider "aws" {
  region = "us-east-1"
}


# Crear VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

# Crear Subnet
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "main_subnet"
  }
}

# Crear Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_igw"
  }
}

# Crear tabla de rutas y asociarla con la Subnet
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "main_route_table"
  }
}


resource "aws_route_table_association" "main_route_table_assoc" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}


# Crear Security Group para SSH
resource "aws_security_group" "ssh_access" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "ssh_access"
  description = "Allow SSH access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir acceso desde cualquier IP, ajusta esto según tus necesidades
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh_access"
  }
}


#resource "aws_instance" "builder" {
#  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
#  instance_type = "t2.micro"
#
#  # Especificar la clave SSH para acceder a la instancia
#  key_name = "my-key"
#
#  tags = {
#    Name = "docker-builder"
#  }
#}

resource "aws_ecr_repository" "my_repo" {
  name = "my-docker-repo"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-ecr-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-profile"
  role = aws_iam_role.ec2_role.name
}


# Crear Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/key.pub")  # Ruta al archivo de clave pública
}

# Crear la instancia EC2
resource "aws_instance" "builder" {
  ami                    = "ami-014d544cfef21b42d"  # Amazon Linux 2 AMI
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
      "sudo amazon-linux-extras install git -y",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "$(aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ${aws_ecr_repository.my_repo.repository_url})",
      "git clone https://github.com/alejorod18/github_actions_hephimerus.git",
      "docker build -t my-docker-repo .",
      "docker tag my-docker-repo:latest ${aws_ecr_repository.my_repo.repository_url}:latest",
      "docker push ${aws_ecr_repository.my_repo.repository_url}:latest",
      # Ejemplo de uso adicional: ejecutar un contenedor Docker
      "docker run -d --name my_container ${aws_ecr_repository.my_repo.repository_url}:latest",
      # Ejemplo de uso adicional: verificar el contenedor en ejecución
      "docker ps"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/key.pem")
      host        = self.public_ip
    }
  }
}