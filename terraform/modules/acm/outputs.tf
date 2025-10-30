output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate_validation.cert.certificate_arn
}