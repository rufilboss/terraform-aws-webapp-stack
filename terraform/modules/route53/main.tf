# Primary A record for the domain
resource "aws_route53_record" "main" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "A"
  
  alias {
    name                   = var.alb_dns
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

  tags = merge(var.tags, {
    Name = "${var.domain}-main-record"
    Type = "Primary A Record"
  })
}

# WWW subdomain redirect
resource "aws_route53_record" "www" {
  count   = var.create_www_record ? 1 : 0
  zone_id = var.zone_id
  name    = "www.${var.domain}"
  type    = "A"
  
  alias {
    name                   = var.alb_dns
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

  tags = merge(var.tags, {
    Name = "www.${var.domain}-record"
    Type = "WWW A Record"
  })
}

# Health check for the primary domain
resource "aws_route53_health_check" "main" {
  count                           = var.enable_health_check ? 1 : 0
  fqdn                           = var.domain
  port                           = 443
  type                           = "HTTPS"
  resource_path                  = var.health_check_path
  failure_threshold              = var.health_check_failure_threshold
  request_interval               = var.health_check_request_interval
  cloudwatch_logs_region         = var.aws_region
  cloudwatch_alarm_region        = var.aws_region
  insufficient_data_health_status = "Failure"

  tags = merge(var.tags, {
    Name = "${var.domain}-health-check"
    Type = "Route53 Health Check"
  })
}

# CloudWatch alarm for health check
resource "aws_cloudwatch_metric_alarm" "health_check" {
  count               = var.enable_health_check ? 1 : 0
  alarm_name          = "route53-health-check-${replace(var.domain, ".", "-")}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "This metric monitors health check status for ${var.domain}"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    HealthCheckId = aws_route53_health_check.main[0].id
  }

  tags = merge(var.tags, {
    Name = "${var.domain}-health-alarm"
    Type = "Health Check Alarm"
  })
}