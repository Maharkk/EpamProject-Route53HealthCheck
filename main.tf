terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.65.0"
    }
  }
}

provider "aws" {
  # Configuration options 
  region = "ap-south-1"
}
resource "aws_vpc" "projectvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "projectvpc"
  }
}
resource "aws_subnet" "projectsubnet" {
  vpc_id     = aws_vpc.projectvpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "projectsubnet"
  }
}
resource "aws_internet_gateway" "projectgateway" {
  vpc_id = aws_vpc.projectvpc.id
  tags = {
    Name = "projectgateway"
  }
}
resource "aws_route_table" "projectroutetable" {
  vpc_id = aws_vpc.projectvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.projectgateway.id
  }

  tags = {
    Name = "projectroutetable"
  }
}
resource "aws_route_table_association" "projectrtassociation" {
  subnet_id      = aws_subnet.projectsubnet.id
  route_table_id = aws_route_table.projectroutetable.id
}
resource "aws_security_group" "projectsecuritygrp" {
  name_prefix = "projectsecuritygrp"
  vpc_id      = aws_vpc.projectvpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_iam_role" "projectiamrole" {
  name = "projectiamrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "projectiamroleattach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.projectiamrole.name
}


data "archive_file" "prjctarchivefile" {
  type        = "zip"
  output_path = "${path.module}/prjctarcfileop.zip"
  source_dir  = "${path.module}/lambda"
}

resource "aws_lambda_function" "prjctlambdafunc" {
  filename         = data.archive_file.prjctarchivefile.output_path
  function_name    = "prjctlambdafunc"
  role             = aws_iam_role.projectiamrole.arn
  handler          = "lambda.handler"
  source_code_hash = data.archive_file.prjctarchivefile.output_base64sha256
  runtime          = "python3.7"
  timeout          = 60
  vpc_config {
    security_group_ids = [aws_security_group.projectsecuritygrp.id]
    subnet_ids         = [aws_subnet.projectsubnet.id]
  }
}

resource "aws_cloudwatch_event_rule" "prjctcldwchevntrule" {
  name        = "prjctcldwchevntrule"
  description = "project CloudWatch Event Rule"

  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "prjctcldwchevnttrgt" {
  rule      = aws_cloudwatch_event_rule.prjctcldwchevntrule.name
  target_id = "prjctcldwchevnttrgt"
  arn       = aws_lambda_function.prjctlambdafunc.arn
}
resource "aws_sns_topic" "prjctsnstopic" {
  name = "prjctsnstopic"
}
resource "aws_sns_topic_subscription" "prjctsnstopicsub" {
  topic_arn = aws_sns_topic.prjctsnstopic.arn
  protocol  = "email"
  endpoint  = "maharkk7781@example.com"
}
resource "aws_cloudwatch_metric_alarm" "prjctcldwtchalrm" {
  alarm_name          = "prjctcldwtchalrm"
  comparison_operator = "GreaterThanThreshold" 
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Alarm for failed Route53 health checks"

  dimensions = {
    HealthCheckId = aws_route53_health_check.prjctrt53hltchck.id
  }

  alarm_actions = [aws_sns_topic.prjctsnstopic.arn]
}

resource "aws_route53_health_check" "prjctrt53hltchck" {
  fqdn              = "google.com"
  type              = "HTTPS"
  port              = 443
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 10

  tags = {
    Name = "prjctgoogle"
  }
}





