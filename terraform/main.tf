################################################################################
# Settings
################################################################################
terraform {
  backend "s3" {
    bucket  = "nakashimn"
    region  = "ap-northeast-3"
    key     = "tfstate/production.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region  = var.region
  profile = "terraform"
}

# AWSの情報
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

################################################################################
# Bathces
################################################################################
module "ecs_ts_dev_template" {
  source                     = "./modules/ecs_dev_ts_template"
  ecs_task_execution_role    = aws_iam_role.ecs_task_execution
  ecs_task_role              = aws_iam_role.ecs_task
  eventbridge_scheduler_role = aws_iam_role.eventbridge_scheduler
  region                     = var.region
  security_group_ids         = [aws_security_group.main.id]
  subnet_ids                 = aws_subnet.public.*.id
  vpc_id                     = aws_vpc.main.id
}

################################################################################
# Services
################################################################################
module "openapi_sample" {
  source                  = "./modules/openapi_sample"
  account_id              = data.aws_caller_identity.current.account_id
  codebuild_role          = aws_iam_role.codebuild
  ecs_task_execution_role = aws_iam_role.ecs_task_execution
  ecs_task_role           = aws_iam_role.ecs_task
  region                  = var.region
  security_group_ids      = [aws_security_group.main.id]
  subnet_ids              = aws_subnet.private.*.id
  vpc_id                  = aws_vpc.main.id
}
