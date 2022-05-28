resource "aws_security_group" "vpc_sg" {
  name        = "${var.platform_name}-vpc-sg"
  description = "Allows ports required"
  vpc_id      = var.create_vpc ? module.vpc.vpc_id : var.vpc_id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Access to an instance"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Client Web Server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Admin Web UI"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, tomap({ "Name" = var.platform_name }))
}

resource "aws_security_group" "kunernetes_nodes" {
  name        = "${var.platform_name}-kubernetes-nodes"
  description = "SG for ${var.platform_name} cluster worker nodes. Managed by Terraform"
  vpc_id      = var.create_vpc ? module.vpc.vpc_id : var.vpc_id

  tags = merge(var.tags, tomap({ "Name" = "${var.platform_name}-kubernetes-nodes" }))
}

resource "aws_security_group_rule" "vpc_tcp" {
  description       = "Allow inbound TCP traffic from VPC"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [var.platform_cidr]
  ipv6_cidr_blocks  = null
  security_group_id = aws_security_group.kunernetes_nodes.id
}
