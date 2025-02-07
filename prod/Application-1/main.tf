terraform {
  backend "s3" {
    bucket  = "myterraform-bucket-state-hsj-t"
    key     = "prod/app1/terraform.tfstate"
    region  = "ap-northeast-2"
    profile = "terraform_user"
    dynamodb_table = "myTerraform-bucket-lock-hsj-t"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform_user"
}

module "prod_alb" {
  source           = "github.com/HongSeungJae00/Terraform_Project_LocalModule//aws-alb?ref=v1.0.0"
  name             = "prod"
  vpc_id           = data.terraform_remote_state.vpc_remote_data.outputs.vpc_id
  public_subnets   = data.terraform_remote_state.vpc_remote_data.outputs.public_subnets
  HTTP_HTTPS_SG_ID = data.terraform_remote_state.vpc_remote_data.outputs.HTTP_HTTPS_SG
}



module "prod_asg" {
  source           = "github.com/HongSeungJae00/Terraform_Project_LocalModule//aws-asg?ref=v1.0.0"
  instance_type    = "t2.micro"
  min_size         = "2"
  max_size         = "4"
  name             = "prod"
  private_subnets  = data.terraform_remote_state.vpc_remote_data.outputs.private_subnets
  SSH_SG_ID        = data.terraform_remote_state.vpc_remote_data.outputs.SSH_SG
  HTTP_HTTPS_SG_ID = data.terraform_remote_state.vpc_remote_data.outputs.HTTP_HTTPS_SG
}
