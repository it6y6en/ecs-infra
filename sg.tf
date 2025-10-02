# SG for LB
resource "aws_security_group" "alb" {
  name        = "ecs-alb-sg"
  description = "ALB SG"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "ecs-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb" {
  description                  = "Allow traffic only on port 80 from allowed IPs"
  for_each          = var.allowed_ips
  security_group_id = aws_security_group.alb.id
  cidr_ipv4   = each.value
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "alb" {
  description                  = "Allow egress traffic only from ALB to ECS"
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "-1"
  tags = {
    Name = "allow-all-to-app"
  }
}

# SG for App
resource "aws_security_group" "app" {
  name        = "ecs-app-sg"
  description = "APP SG"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "ecs-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  description                  = "Allow ingress traffic only from ALB to ECS"
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "-1"
  tags = {
    Name = "allow-all-from-alb"
  }
}

resource "aws_vpc_security_group_egress_rule" "app_vpce_https" {
  description       = "Allow HTTPS to VPC endpoints"
  security_group_id = aws_security_group.app.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "allow-https-to-endpoints"
  }
}

# SG for endpoints
resource "aws_security_group" "vpce" {
  name        = "ecs-endpoints-sg"
  description = "VPC Endpoints SG"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "ecs-endpoints-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "endpoint" {
  description       = "Allow HTTPS from VPC"
  security_group_id = aws_security_group.vpce.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = aws_vpc.this.cidr_block
  tags = {
    Name = "allow-https-from-vpc"
  }
}

resource "aws_vpc_security_group_egress_rule" "endpoint" {
  description       = "Allow all egress"
  security_group_id = aws_security_group.vpce.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
