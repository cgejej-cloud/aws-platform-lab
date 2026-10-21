variable "project" {
  description = "리소스 이름·태그에 쓰는 프로젝트 이름"
  type        = string
  default     = "aws-platform-lab"
}

variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR (IGW 경로 있음)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private Subnet CIDR (IGW 경로 없음)"
  type        = string
  default     = "10.0.11.0/24"
}

variable "my_ip_cidr" {
  description = "Tool API(8000) 접근을 허용할 내 공인 IP (예: 1.2.3.4/32). CI에서 Secret으로 주입"
  type        = string
}

variable "enable_ec2" {
  description = "EC2 생성 여부. 계정 프리티어 유형 확인 전까지 false"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "EC2 타입. 콘솔에서 'Free tier eligible' 표시된 타입으로 지정"
  type        = string
  default     = "t3.micro"
}
