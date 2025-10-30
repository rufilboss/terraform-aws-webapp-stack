output "auto_scaling_group_name" {
  description = "Auto Scaling Group name"
  value       = "rstudio-instance"  # Since this is a single instance, not ASG
}