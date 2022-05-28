variable "create_vpc" {
  description = "Whether to create a new VPC or use existing one"
  type        = bool
  default     = true
}

variable "create_cluster" {
  description = "Whether to create EKS cluster and required stuff. Maybe set to false if there are any additional steps between VPC and EKS cluster deployment required"
  type        = bool
  default     = true
}

variable "region" {
  description = "The AWS region to deploy the cluster into (e.g. eu-central-1)"
  type        = string
}

variable "aws_profile" {
  description = "The AWS profile name to use for running terraform, look for the name in the ~/.aws/config local file"
  type        = string
}

# variable "role_arn" {
#   description = "The AWS IAM role arn to assume for running terraform (e.g. arn:aws:iam::012345678910:role/EKSDeployerRole)"
#   type        = string
# }

variable "platform_name" {
  description = "The name of the cluster that is used for tagging resources. Match the [a-z0-9_-]"
  type        = string
}

variable "platform_domain_name" {
  description = "The name of existing DNS zone for platform"
  type        = string
}

variable "cf_acm_certificate_arn" {
  description = "ACM certificate arn for CloudFront Distribution. It must be in the us-east-1 region according to the requirement for CloudFront distribution & ALB deployment"
  type        = string
  default     = ""
}

variable "alb_acm_certificate_arn" {
  description = "ACM certificate arn for Application Load Balancer. It must be in the ALB region according to the requirement for ALB deployment"
  type        = string
  default     = ""
}

variable "subnet_azs" {
  description = "Available zones of your future or existing subnets"
  type        = list(any)
  default     = []
}

variable "platform_cidr" {
  description = "CIRD of your future or existing VPC"
  type        = string
}

variable "private_cidrs" {
  description = "CIRD of your future or existing VPC"
  type        = list(any)
  default     = []
}

variable "public_cidrs" {
  description = "CIRD of your future or existing VPC"
  type        = list(any)
  default     = []
}

variable "vpc_id" {
  description = "VPC id in which we deploy EKS cluster in case create_vpc = false"
  type        = string
  default     = ""
}

variable "private_subnets_id" {
  description = "A list of subnets to place the EKS cluster and workers within in case create_vpc = false"
  type        = list(any)
  default     = []
}

variable "public_subnets_id" {
  description = "A list of subnets to place the LB and other external resources in case create_vpc = false"
  type        = list(any)
  default     = []
}

variable "ssl_policy" {
  description = "Predefined SSL security policy for ALB https listeners"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.18"
}

variable "key_name" {
  description = "The name of AWS ssh key to create and attach to all created nodes"
  type        = string
}

variable "enable_irsa" {
  description = "Whether to create OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = false
}

variable "manage_cluster_iam_resources" {
  description = "Whether to let the module manage cluster IAM resources. If set to false, cluster_iam_role_name must be specified"
  type        = bool
  default     = true
}

variable "cluster_iam_role_name" {
  description = "A cluster IAM role name (not ARN) to run EKS cluster"
  type        = string
}

variable "manage_worker_iam_resources" {
  description = "Whether to let the module manage worker IAM resources. If set to false, iam_instance_profile_name must be specified for workers"
  type        = bool
  default     = true
}

variable "worker_iam_instance_profile_name" {
  description = "An instance profile name (not ARN) to run EKS worker nodes"
  type        = string
}

variable "kubeconfig_aws_authenticator_command" {
  description = "Command to use to fetch AWS EKS credentials. Set to 'aws' if AWS CLI version is 1.16.156 or later"
  type        = string
  default     = "aws-iam-authenticator"
}

variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = \"edp_user\"}."
  type        = map(string)
  default     = {}
}

variable "add_userdata" {
  description = "Additional userdata for launch template"
  type        = string
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_roles" {
  description = "Additional IAM Roles to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
}

variable "demand_instance_types" {
  description = "AWS instance type to build nodes for demand pool"
  type        = list(any)
  default     = ["r5.large"]
}

variable "spot_instance_types" {
  description = "AWS instance type to build nodes for spot pool"
  type        = list(any)
  default     = ["r5.large", "m5.large", "t3.large"]
}

variable "mongo_instance_type" {
  description = "AWS instance type to build nodes for Mongo DB"
  type        = string
  default     = "t3.micro"
}

variable "nginx_instance_type" {
  description = "AWS instance type to build nodes for NGINX"
  type        = string
  default     = "t3.micro"
}

variable "openvpn_instance_type" {
  description = "AWS instance type to build node for OpenVPN"
  type        = string
  default     = "t3.small"
}

variable "openvpn_ami" {
  description = "AWS instance AMI to build node for OpenVPN"
  type        = string
  default     = "ami-05adc869887a68852"
}

variable "tenants" {
  description = "Inputs for worker groups launch temaplate in case of multitenancy deployment"
  type        = any
  default     = {}
}

variable "extended_outputs" {
  description = "Whether to show extended outputs"
  type        = bool
  default     = false
}
variable "TF_CLOUD_ORGANIZATION" {
  description = "Whether to show extended outputs"
  type        = string
  default     = "aws-es-deployment-demo"
}
