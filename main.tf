# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
# Fiap Pos tech

terraform {
  backend "remote"{
    organization = "DevopsFiap_Lucas"
    workspaces{
      name = "rds-mysql"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  required_version = ">= 1.1.0"

  }
}

provider "aws" {
  region        = "us-east-1"
  access_key    = ${{ secrets.AWS_ACCESS_KEY_ID }}
  secret_key    = ${{ secrets.AWS_SECRET_ACCESS_KEY}}
  session_token = ${{ secrets.AWS_SESSION_TOKEN}}
}

resource "aws_db_instance" "mysql" {
  identifier             = "mysql-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "mysql-db"
  username               = ${{ secrets.db_user}}
  password               = ${{ secrets.db_password}}
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = true
}
