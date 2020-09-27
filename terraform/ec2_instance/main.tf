data "aws_ami" "win" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-1909-English-Core-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"]
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    user_data = file("${path.module}/functions.ps1")
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.win.id
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.profile.id

  user_data = data.template_file.user_data.rendered

  tags = {
    Name = "SSM-Provisioning-Demo"
  }

}

resource "aws_iam_instance_profile" "profile" {
  name = "ssm_instance_profile"

  role = aws_iam_role.role.id
}

resource "aws_iam_role" "role" {
  name = "test_role"

  assume_role_policy = data.aws_iam_policy_document.pol.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "pol" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}