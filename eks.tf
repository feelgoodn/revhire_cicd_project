data "aws_caller_identity" "current" {}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = "revhire-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  # EKS Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.private_subnets


  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = "t2.medium"
  }

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    revhire-node = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t2.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }


  # Cluster access entry
  enable_cluster_creator_admin_permissions = true

  # access_entries = {
  #   admin = {
  #     kubernetes_groups = ["system:masters"]
  #     principal_arn     = data.aws_caller_identity.current.arn

  #     policy_associations = {
  #       revhire_policy = {
  #         policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  #         access_scope = {
  #           namespaces = ["default"]
  #           type       = "namespace"
  #         }
  #       }
  #     }
  #   }
  # }


  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
