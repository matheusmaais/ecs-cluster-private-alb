output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.internal.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.internal.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID"
  value       = aws_lb.internal.zone_id
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.ecs.arn
}

output "listener_arn" {
  description = "Listener ARN"
  value       = aws_lb_listener.http.arn
}
