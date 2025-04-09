output "private_subnet_ids" {
  value = aws_subnet.sn2-private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.sn1-public[*].id
}


output "vpc_id" {
  value = aws_vpc.vpc.id
}
