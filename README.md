# aws-platform-lab

AWS 프리티어 범위에서 **네트워크·보안·IaC·CI/CD·모니터링**을 직접 구성해 보는 개인 실습 저장소입니다.

## 구성 (Day 1)

```
GitHub (PR → main) ── GitHub Actions ──OIDC──▶ IAM Role
                                   │ terraform plan / 승인 후 apply
┌──────────────── VPC 10.0.0.0/16 ───────────────────────────┐
│ Public Subnet  : 0.0.0.0/0 → Internet Gateway               │
│   EC2 (선택, SSH 미개방 · SSM 접속 · IMDSv2)                  │
│   Security Group: 8000 ← 내 IP만                             │
│ Private Subnet : 인터넷 경로 없음, S3 Gateway Endpoint만       │
└────────────────────────────────────────────────────────────┘
S3 data 버킷 (EC2 Role은 data/ prefix 읽기만)
```

## 설계 이유
| 결정 | 이유 |
|---|---|
| Public / Private Subnet을 Route Table로 분리 | 인터넷 노출 범위를 라우팅으로 통제 |
| NAT Gateway 미사용, S3 Gateway Endpoint 사용 | 비용 0원으로 Private Subnet의 S3 접근 |
| SSH(22) 미개방, SSM Session Manager 접속 | 키 관리·포트 노출 없이 서버 접근 |
| GitHub OIDC 임시 자격증명 | 저장소에 AWS Access Key를 두지 않음 |
| PR에서 plan, 승인 후 apply | 인프라 변경을 리뷰·승인 절차로 통제 |
| state: S3 (버전 관리·암호화·잠금) | 실행 간 상태 공유, 잘못된 덮어쓰기 복구 |
| default_tags (Project/Owner/Env) | 리소스·비용 추적 |

## CI/CD
- **PR**: `terraform fmt` → `validate` → `plan` → plan 결과를 PR 코멘트로
- **main 병합**: `production` 환경 승인 → `terraform apply`
- 필요한 Secrets: `AWS_ROLE_ARN`, `TF_STATE_BUCKET`, `MY_IP_CIDR`

## Bootstrap (1회, CloudShell)
state 버킷과 GitHub OIDC Provider·Role은 이 파이프라인이 동작하기 위한 전제라 CloudShell에서 한 번만 직접 생성했습니다.

## 비용
프리티어/무료 리소스만 사용합니다. NAT Gateway, Interface Endpoint, EKS는 만들지 않습니다.
