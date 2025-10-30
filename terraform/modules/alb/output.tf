output "arn" {
  description = "ALB ARN"
  value       = aws_lb.alb.arn
}

output "arn_suffix" {
  description = "ALB ARN suffix"
  value       = aws_lb.alb.arn_suffix
}

output "dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.alb.dns_name
}

output "zone_id" {
  description = "ALB zone ID"
  value       = aws_lb.alb.zone_id
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.tg.arn
}

output "security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb_sg.id
}