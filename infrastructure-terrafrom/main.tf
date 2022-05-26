module "vpc" {
  source = "./modules/vpc"

  create_vpc = var.create_vpc

  name = var.platform_name

  cidr            = var.platform_cidr
  azs             = var.subnet_azs
  private_subnets = var.private_cidrs
  public_subnets  = var.public_cidrs

  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = var.tags
}



# locals {
#   kubernetes_target_groups = [
#     {
#       "name"                 = "${var.platform_name}-kubernetes-tcp-9200"
#       "backend_port"         = "9200"
#       "backend_protocol"     = "TCP"
#       "deregistration_delay" = "60"
#     },
#     {
#       "name"                 = "${var.platform_name}-kubernetes-tcp-9300"
#       "backend_port"         = "9300"
#       "backend_protocol"     = "TCP"
#       "deregistration_delay" = "60"
#     },
#     {
#       "name"                 = "${var.platform_name}-kubernetes-tcp-80"
#       "backend_port"         = "80"
#       "backend_protocol"     = "TCP"
#       "deregistration_delay" = "60"
#     },
#     {
#       "name"                 = "${var.platform_name}-kubernetes-tcp-443"
#       "backend_port"         = "443"
#       "backend_protocol"     = "TCP"
#       "deregistration_delay" = "60"
#     },

#   ]
# }

# module "nlb_kubernetes" {
#   source = "./modules/nlb_kubernetes"

#   create_lb = var.create_cluster

#   name = "${var.platform_name}-nlb-kubernetes"

#   load_balancer_type = "network"
#   internal           = false

#   vpc_id  = var.create_vpc ? module.vpc.vpc_id : var.vpc_id
#   subnets = var.create_vpc ? module.vpc.public_subnets : var.public_subnets_id

#   target_groups = local.kubernetes_target_groups

#   http_tcp_listeners = [
#     {
#       port               = 9200
#       protocol           = "TCP"
#       target_group_index = 0
#     },
#     {
#       port               = 9300
#       protocol           = "TCP"
#       target_group_index = 1
#     },
#     {
#       port               = 80
#       protocol           = "TCP"
#       target_group_index = 2
#     },
#     {
#       port               = 443
#       protocol           = "TCP"
#       target_group_index = 3
#     }
#   ]

#   tags = var.tags
# }

module "eks" {
  source = "./modules/eks"

  create_eks = var.create_cluster

  cluster_name = var.platform_name

  vpc_id  = var.create_vpc ? module.vpc.vpc_id : var.vpc_id
  subnets = var.create_vpc ? module.vpc.public_subnets : var.public_subnets_id

  cluster_version = var.cluster_version
  enable_irsa     = var.enable_irsa

  cluster_enabled_log_types     = []
  cluster_log_retention_in_days = 14

  manage_cluster_iam_resources = var.manage_cluster_iam_resources
  manage_worker_iam_resources  = var.manage_worker_iam_resources
  cluster_iam_role_name        = var.manage_cluster_iam_resources ? local.cluster_iam_role_name_to_create : var.cluster_iam_role_name
  workers_role_name            = var.manage_worker_iam_resources ? local.worker_iam_role_name_to_create : ""

  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true
  cluster_create_security_group   = false
  worker_create_security_group    = false

  cluster_security_group_id = local.default_security_group_id
  worker_security_group_id  = local.default_security_group_id

  kubeconfig_aws_authenticator_command       = var.kubeconfig_aws_authenticator_command
  kubeconfig_aws_authenticator_command_args  = var.kubeconfig_aws_authenticator_command == "aws" ? ["eks", "get-token", "--cluster-name", element(concat(data.aws_eks_cluster_auth.cluster[*].name, [""]), 0)] : []
  kubeconfig_aws_authenticator_env_variables = var.kubeconfig_aws_authenticator_env_variables

  worker_groups_launch_template = local.worker_groups_launch_template_tenants

  map_users = var.map_users
  map_roles = var.map_roles

  tags = var.tags
}
