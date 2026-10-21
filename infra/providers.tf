provider "aws" {
  region = var.region

  # 모든 리소스에 공통 태그 → 비용·소유자 추적 (거버넌스)
  default_tags {
    tags = {
      Project = var.project
      Owner   = "inbanseok"
      Env     = "lab"
      Managed = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}
