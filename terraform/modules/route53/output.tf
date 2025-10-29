output "domain_name" {
  description = "The primary domain name"
  value       = var.domain
}

output "www_domain_name" {
  description = "The www subdomain name (if created)"
  value       = var.create_www_record ? "www.${var.domain}" : null
}

output "main_record_name" {
  description = "The name of the main A record"
  value       = aws_route53_record.main.name
}

output "main_record_fqdn" {
  description = "The FQDN of the main A record"
  value       = aws_route53_record.main.fqdn
}

output "www_record_name" {
  description = "The name of the www A record (if created)"
  value       = var.create_www_record ? aws_route53_record.www[0].name : null
}

output "www_record_fqdn" {
  description = "The FQDN of the www A record (if created)"
  value       = var.create_www_record ? aws_route53_record.www[0].fqdn : null
}

output "health_check_id" {
  description = "The ID of the Route53 health check (if enabled)"
  value       = var.enable_health_check ? aws_route53_health_check.main[0].id : null
}

output "health_check_arn" {
  description = "The ARN of the Route53 health check (if enabled)"
  value       = var.enable_health_check ? aws_route53_health_check.main[0].arn : null
}

output "cloudwatch_alarm_name" {
  description = "The name of the CloudWatch alarm for health check (if enabled)"
  value       = var.enable_health_check ? aws_cloudwatch_metric_alarm.health_check[0].alarm_name : null
}

output "zone_id" {
  description = "The Route53 hosted zone ID used"
  value       = var.zone_id
}