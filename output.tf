output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets" {
  value = [for i in aws_subnet.public : i.id]
}

output "private_subnets" {
  value = [for i in aws_subnet.private : i.id]
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "alb_listener_arn" {
  value = aws_lb_listener.this.arn
}

output "alb_endpoint" {
  value = aws_lb.this.dns_name
}
