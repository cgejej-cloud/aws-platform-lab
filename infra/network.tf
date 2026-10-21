# ---------------------------------------------------------------
# VPC / Subnet / Routing — 전부 무료 리소스
# Public  : Route Table에 0.0.0.0/0 → IGW 경로가 있음
# Private : IGW 경로 없음 → 인터넷 불가, S3는 Gateway Endpoint로만
# NAT Gateway는 유료라 만들지 않는다.
# ---------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.project}-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false # 공인 IP는 인스턴스에서 명시적으로만 부여

  tags = { Name = "${var.project}-public-a", Tier = "public" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = { Name = "${var.project}-private-a" , Tier = "private"}
}

# Public Route Table: 기본 경로를 IGW로
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "${var.project}-rt-public" }
}

# Private Route Table: 기본 경로 없음 (VPC 내부 local 경로만)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project}-rt-private" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# S3 Gateway Endpoint (무료): Private Subnet에서도 인터넷 없이 S3 접근
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = { Name = "${var.project}-vpce-s3" }
}

# ---------------------------------------------------------------
# Security Group: Tool API(8000)는 내 IP만, SSH(22)는 열지 않음
# 서버 접속은 SSM Session Manager 사용
# ---------------------------------------------------------------
resource "aws_security_group" "app" {
  name        = "${var.project}-app"
  description = "Tool API access from my IP only. No SSH."
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${var.project}-sg-app" }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_my_ip" {
  security_group_id = aws_security_group.app.id
  description       = "Tool API from my IP"
  cidr_ipv4         = var.my_ip_cidr
  ip_protocol       = "tcp"
  from_port         = 8000
  to_port           = 8000
}

resource "aws_vpc_security_group_egress_rule" "app_https_out" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS out (SSM, S3, package install)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "app_http_out" {
  security_group_id = aws_security_group.app.id
  description       = "HTTP out (OS package repositories)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}
