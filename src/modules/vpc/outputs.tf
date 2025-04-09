output "private_subnet_ids" {
  value = aws_subnet.sn2-private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.sn1-public[*].id
}


output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "ecs_tasks_security_group_id" {
  value = aws_security_group.sg.id
}
