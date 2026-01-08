output "zone_id" {
  description = "Route53 private hosted zone ID"
  value       = aws_route53_zone.private.zone_id
}

output "zone_name" {
  description = "Route53 private hosted zone name"
  value       = aws_route53_zone.private.name
}

output "cdn_fqdn" {
  description = "Full CDN domain name"
  value       = aws_route53_record.cdn.fqdn
}

output "name_servers" {
  description = "Name servers for the hosted zone"
  value       = aws_route53_zone.private.name_servers
}
