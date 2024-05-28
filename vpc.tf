# # Configure the AWS Provider
# provider "aws" {
#   region                   = "us-east-1"
#   shared_config_files      = ["/root/.aws/config"]
#   shared_credentials_files = ["/root/.aws/credentials"]
#   profile                  = "default"

# }

# Create VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "revhire-tf-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]



  enable_nat_gateway = true
  enable_vpn_gateway = true
  # map_public_ip_on_launch = true




  tags = {
    name        = "jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }
}


#Security groups
module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "user-service"
  description = "Security group for user and job service"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    },
  ]


  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = {
    Name = "revhire-sg"
  }
}




