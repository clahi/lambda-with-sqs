data "aws_ami" "this" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_key_pair" "demo-key" {
  key_name   = "demo-key"
  public_key = file("${path.module}/demo-key.pub")
}


resource "aws_instance" "my-instance" {
  instance_type = "t3.micro"
  ami           = data.aws_ami.this.id
  key_name      = aws_key_pair.demo-key.key_name

  tags = {
    Name = "my-instance"
  }
}

