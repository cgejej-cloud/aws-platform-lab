output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "data_bucket" {
  value = aws_s3_bucket.data.bucket
}

output "instance_id" {
  value = var.enable_ec2 ? aws_instance.app[0].id : null
}
