# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM role for EC2 instances
resource "aws_iam_role" "chat_app_role" {
  name = "${var.environment}-chat-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-chat-app-role"
    Environment = var.environment
  }
}

# IAM instance profile
resource "aws_iam_instance_profile" "chat_app_profile" {
  name = "${var.environment}-chat-app-profile"
  role = aws_iam_role.chat_app_role.name
}

# IAM policy for CloudWatch Logs
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "${var.environment}-chat-app-logs-policy"
  description = "Allow EC2 instances to send logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach the CloudWatch policy to the IAM role
resource "aws_iam_role_policy_attachment" "cloudwatch_logs_attachment" {
  role       = aws_iam_role.chat_app_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

# IAM policy for S3 access (for media uploads)
resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.environment}-chat-app-s3-policy"
  description = "Allow EC2 instances to access S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.environment}-chat-media/*",
          "arn:aws:s3:::${var.environment}-chat-media"
        ]
      }
    ]
  })
}

# Attach the S3 policy to the IAM role
resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.chat_app_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Launch template for the chat application
resource "aws_launch_template" "chat_app" {
  name_prefix   = "${var.environment}-chat-app-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.chat_app_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_security_group_id]
    delete_on_termination       = true
  }

  # Only use key_name if provided
  dynamic "key_pair" {
    for_each = var.key_name != "" ? [1] : []
    content {
      key_name = var.key_name
    }
  }

  # User data script to set up the chat application
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    
    # Install docker-compose
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Set environment variables
    cat > /etc/environment <<EOL
DB_HOST=${var.db_endpoint}
REDIS_HOST=${var.redis_endpoint}
ENV=${var.environment}
EOL

    # Create app directory
    mkdir -p /app
    
    # Pull and run the chat application container
    docker pull myrepo/chat-app:latest
    
    # Create docker-compose.yml
    cat > /app/docker-compose.yml <<EOL
version: '3'
services:
  chat-app:
    image: myrepo/chat-app:latest
    ports:
      - "8080:8080"
    environment:
      - DB_HOST=\${DB_HOST}
      - REDIS_HOST=\${REDIS_HOST}
      - ENV=\${ENV}
    restart: always
    logging:
      driver: awslogs
      options:
        awslogs-group: ${var.environment}-chat-app-logs
        awslogs-region: $(curl -s http://169.254.169.254/latest/meta-data/placement/region)
        awslogs-stream-prefix: chat
EOL
    
    # Start the application
    cd /app && docker-compose up -d
    
    # Create CloudWatch Logs group
    aws logs create-log-group --log-group-name ${var.environment}-chat-app-logs --region $(curl -s http://169.254.169.254/latest/meta-data/placement/region)
    EOF
  )
}

# Auto Scaling Group for the chat application
resource "aws_autoscaling_group" "chat_app" {
  name                = "${var.environment}-chat-app-asg"
  vpc_zone_identifier = var.private_app_subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.chat_app.id
    version = "$Latest"
  }

  # Attach to ALB target group
  target_group_arns = [var.target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  # Use instance refresh for rolling updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-chat-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

# CloudWatch alarm for scaling up based on CPU
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.environment}-chat-app-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.chat_app.name
  }

  alarm_description = "Scale up if CPU utilization is above 70% for 2 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

# CloudWatch alarm for scaling down based on CPU
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.environment}-chat-app-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.chat_app.name
  }

  alarm_description = "Scale down if CPU utilization is below 30% for 2 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}

# Auto Scaling policy for scaling up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.environment}-chat-app-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.chat_app.name
}

# Auto Scaling policy for scaling down
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.environment}-chat-app-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.chat_app.name
}
