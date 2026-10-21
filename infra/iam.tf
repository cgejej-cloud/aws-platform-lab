# ---------------------------------------------------------------
# EC2 Instance Role — 최소 권한
#  - SSM Session Manager 접속용 관리형 정책만
#  - 데이터 버킷은 data/ prefix 읽기만 허용 (Day 2 Tool API용)
# ---------------------------------------------------------------

resource "aws_iam_role" "ec2" {
  name = "${var.project}-ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ec2_data_read" {
  name = "data-read-only"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListDataPrefix"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.data.arn
        Condition = {
          StringLike = { "s3:prefix" = ["data/*"] }
        }
      },
      {
        Sid      = "ReadDataObjects"
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.data.arn}/data/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project}-ec2"
  role = aws_iam_role.ec2.name
}
