# Application Load Balancer for the chat application
resource "aws_lb" "chat_alb" {
  name               = "${var.environment}-chat-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = true

  # Enable access logs in production
  dynamic "access_logs" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      bucket  = "${var.environment}-chat-alb-logs"
      prefix  = "alb-logs"
      enabled = true
    }
  }

  idle_timeout = 300 # 5 minutes timeout for WebSocket connections

  tags = {
    Name        = "${var.environment}-chat-alb"
    Environment = var.environment
  }
}

# Target group for chat application
resource "aws_lb_target_group" "chat_app" {
  name     = "${var.environment}-chat-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  # Configure for WebSocket support
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400 # 24 hours
    enabled         = true
  }

  tags = {
    Name        = "${var.environment}-chat-app-tg"
    Environment = var.environment
  }
}

# HTTP listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.chat_alb.arn
  port              = 80
  protocol          = "HTTP"

  # Redirect to HTTPS if certificate is provided, otherwise forward to target group
  dynamic "default_action" {
    for_each = var.certificate_arn != "" ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.certificate_arn == "" ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.chat_app.arn
    }
  }
}

# HTTPS listener (conditional creation)
resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.chat_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chat_app.arn
  }
}
