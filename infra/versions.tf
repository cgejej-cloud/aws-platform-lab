terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # bucket은 계정 번호가 들어가므로 코드에 두지 않고
  # CI에서 -backend-config="bucket=..." 으로 주입한다.
  backend "s3" {
    key          = "infra/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
