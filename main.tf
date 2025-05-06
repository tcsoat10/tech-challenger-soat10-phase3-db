# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
# Fiap Pos tech

terraform {
  backend "remote" {
    organization = "DevopsFiap_Lucas"
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

resource "aws_db_instance" "mysql" {
  identifier        = "mysql-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  db_name           = var.db_name
  username          = var.db_user
  password          = var.db_password
  #  db_subnet_group_name   = aws_db_subnet_group.default.name
  #  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot = true
  publicly_accessible = true
}
