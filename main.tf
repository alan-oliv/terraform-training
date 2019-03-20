provider "aws" {
  # access_key = "ACCESS_KEY_HERE"
  # secret_key = "SECRET_KEY_HERE"
  region = "us-east-1"
}

// Por padrão o terraform infere as dependências de acordo com as expressões utilizadas
data "aws_ami" "amz_ec2" {
  most_recent = true

  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

// Provisioners são usados no momento da criação de recursos, quando é necessário executar algum tipo de configuração inicial como transferir arquivos ou executar algum script ou ferramenta.
resource "aws_instance" "instance_a" {
  ami           = "${data.aws_ami.amz_ec2.id}"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo 'Hello world!'"
  }

  tags = {
    Name = "Instance-A"
  }
}

// Se um provisioner falha durante a criação, o recurso é criado porém é marcado como tainted pelo Terraform.
// Durante o próximo apply, recursos marcados como tainted são recriados.
resource "aws_instance" "instance_b" {
  ami           = "${data.aws_ami.amz_ec2.id}"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "some-unknown-command"
  }

  tags = {
    Name = "Instance-B"
  }
}

// Provisioners podem ser especificados para serem executados no momento do destroy.
// Esses provisioners são executados antes do recurso ser destruído.
// Provisioners de destroy só são executados caso a configuração do recurso ainda exista nos arquivos do Terraform, se o recurso for removido do arquivo o provisioner não é executado.
// Mais informações em: https://www.terraform.io/docs/provisioners/
resource "aws_instance" "instance_c" {
  ami           = "${data.aws_ami.amz_ec2.id}"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    when    = "destroy"
    command = "echo 'Goodbye world!'"
  }

  tags = {
    Name = "Instance-C"
  }
}
