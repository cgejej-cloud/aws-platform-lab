# ---------------------------------------------------------------
# EC2 (enable_ec2 = true 일 때만 생성)
#  - 계정의 프리티어 유형을 확인한 뒤 별도 PR로 켠다.
#  - Public Subnet, 공인 IP 부여, SSH 키 없음 → SSM으로 접속
#  - IMDSv2 강제, 루트 볼륨 암호화
# ---------------------------------------------------------------

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "app" {
  count = var.enable_ec2 ? 1 : 0

  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = true

  metadata_options {
    http_tokens = "required" # IMDSv2
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  user_data = <<-EOT
    #!/bin/bash
    dnf install -y docker
    systemctl enable --now docker
    usermod -aG docker ssm-user || true
  EOT

  tags = { Name = "${var.project}-app" }

  lifecycle {
    ignore_changes = [ami] # 최신 AMI가 나와도 인스턴스를 재생성하지 않음
  }
}
