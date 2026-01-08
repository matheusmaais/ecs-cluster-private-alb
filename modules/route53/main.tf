resource "aws_route53_zone" "private" {
  name = var.domain_name

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-zone"
  }
}

resource "aws_route53_record" "cdn" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "${var.cdn_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
