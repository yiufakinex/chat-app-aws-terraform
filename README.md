# Chat Application - AWS with Terraform

## Table of Contents

<ol>
  <li><a href="#about">About</a></li>
  <li><a href="#Architecture Overview">Architecture Overview</a></li>
  <li><a href="#Advanced Implementation">Deployment</a></li>
</ol>

## About
An end-to-end deployment of a scalable and secure real-time Chat application using AWS infrastructure, managed and automated with Terraform.

## Architecture Overview

The infrastructure includes the following components:

- **Networking**: VPC with public and private subnets across multiple availability zones
- **Security**: Security groups following the principle of least privilege
- **Compute**: Auto Scaling Groups with launch templates for EC2 instances
- **Load Balancing**: Application Load Balancer with WebSocket support
- **Database**: Amazon RDS for PostgreSQL with backups and optional multi-AZ deployment
- **Caching**: ElastiCache Redis for message broker and session management
- **Storage**: S3 for media file storage and user uploads
- **DNS Management**: Route 53 for domain management and routing
- **Content Delivery**: CloudFront and S3 for static asset delivery
- **Monitoring**: CloudWatch for logs and metrics

## Advanced Implementation

While this portfolio project demonstrates a cost-effective setup, I'm also familiar with designing robust AWS architectures for production chat applications including:

* VPC with public/private subnets for enhanced security - application servers in private subnets
* RDS with Multi-AZ deployment for database high availability and failover
* Route53 for custom domain management with health checks
* Application Load Balancer with WebSocket support and sticky sessions
* Auto Scaling groups configured for chat traffic patterns
* ElastiCache (Redis) for STOMP message broker and session management
* S3 for media file storage with presigned URLs for secure access
* CloudFront for static asset delivery and additional DDoS protection
* IAM roles with least privilege for EC2 instances and services
* CloudWatch for comprehensive monitoring and alerting
* WAF for rate limiting and protection against common web vulnerabilities
