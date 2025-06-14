# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
# Fiap Pos tech

terraform {
  backend "remote" {
    organization = "10SOAT_TC3"
    workspaces {
      name = "mysql-db"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }

  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "vpc" {
  cidr_block = "172.31.0.0/16"
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_security_group" "eks_sg" {
  filter {
    name   = "group-name"
    values = ["eks-cluster-sg-soat10tc-cluster-eks*"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-mysql-sg"
  description = "Allow inbound traffic to RDS MySQL instance"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description     = "Allow MySQL traffic from EKS cluster"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [data.aws_security_group.eks_sg.id]
  }

  tags = {
    Name = "rds-mysql-sg"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "mysql-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "mysql_db"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = true
  apply_immediately      = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
