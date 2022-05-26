# Check out all the inputs based on the comments below and fill the gaps instead <...>
# More details on each variable can be found in the variables.tf file

create_vpc     = true # set to true if you'd like to create a new VPC or false if use existing
create_cluster = true # set to false if there are any additional manual steps required between VPC and EKS cluster deployment

region                  = "eu-central-1"
aws_profile             = "default"
# role_arn                = "arn:aws:iam::075110123191:role/terrafrom-deployer"
# cf_acm_certificate_arn  = "arn:aws:acm:us-east-1:075110123191:certificate/f7c21623-14ed-4506-beb9-1ba88e369435"    # The ACM certificate must be in the us-east-1 region. Requirement for CloudFront distribution deployment
# alb_acm_certificate_arn = "arn:aws:acm:eu-central-1:075110123191:certificate/7726b4e7-a909-4880-9a91-8662c28d0178" # The ACM certificate must be in the ALB region. Requirement for Application Load Balancer deployment
# acm_certificate_arn     = "arn:aws:acm:eu-central-1:075110123191:certificate/7726b4e7-a909-4880-9a91-8662c28d0178" # The ACM certificate must be in the ALB region. Requirement for Application Load Balancer deployment

platform_name        = "aws-dev-es-cloud"            # the name of the cluster and AWS resources
platform_domain_name = "aws-dev-es-cloud.local" # must be created as a prerequisite

# The following will be created or used existing depending on the create_vpc value
subnet_azs    = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
platform_cidr = "10.161.0.0/16"
private_cidrs = ["10.161.0.0/20", "10.161.16.0/20", "10.161.32.0/20"]
public_cidrs  = ["10.161.208.0/20", "10.161.224.0/20", "10.161.240.0/20"]

#nat_gateway_cidr = ["3.72.69.251/32", "18.159.188.57/32", "18.193.60.7/32"]

# EKS cluster configuration
cluster_version = "1.21"
key_name        = "aws-dev-es-cloud-key-pair" # must be created as a prerequisite
enable_irsa     = true


# Define if IAM roles should be created during the deployment or used existing ones
manage_cluster_iam_resources     = true # if set to false, cluster_iam_role_name must be specified
manage_worker_iam_resources      = true # if set to false, worker_iam_instance_profile_name must be specified for workers
cluster_iam_role_name            = ""
worker_iam_instance_profile_name = ""

# demand_instance_types = ["r5.large"]
# spot_instance_types   = ["r5.large", "r4.large"]
# mongo_instance_type   = "c6g.2xlarge"
# nginx_instance_type   = "c5a.large"
# openvpn_instance_type = "c6g.large"

demand_instance_types = ["r5.large"]
spot_instance_types   = ["r5.large", "r4.large"] # need to ensure we use nodes with more memory

# Define CIDR blocks and/or prefix lists if any to whitelist for public access on LBs

# ingress_cidr_blocks     = ["49.237.4.0/24", "3.72.69.251/32", "18.159.188.57/32", "18.193.60.7/32"]
# ingress_prefix_list_ids = []

# ingress_prefix_list_ids_customer = {
# "80"  = ["pl-01631bae7e8d5947a"]
# "443" = ["pl-01631bae7e8d5947a"]
# }

# Define existing security groups ids if any in order to whitelist for public access on LBs. Makes sense with create_vpc = false only.
# public_security_group_ids = []

# Uncomment if your AWS CLI version is 1.16.156 or later
kubeconfig_aws_authenticator_command = "aws"

# Environment varibles to put into kubeconfig file to use when executing the authentication, such as AWS profile of IAM user for authentication
kubeconfig_aws_authenticator_env_variables = {
  AWS_PROFILE = "default"
}

# add_userdata = ""

add_userdata = <<EOF
export TOKEN=$(aws ssm get-parameter --name edprobot --query 'Parameter.Value' --region eu-central-1 --output text)
cat <<DATA > /var/lib/kubelet/config.json
{
  "auths":{
    "https://index.docker.io/v1/":{
      "auth":"$TOKEN"
    }
  }
}
DATA
EOF

map_users = [
  {
    "userarn" : "arn:aws:iam::723915311050:user/dmytro",
    "username" : "dmytro",
    "groups" : ["system:masters"]
  }
]

map_roles = [
  {
    "rolearn" : "arn:aws:iam::723915311050:role/EKSClusterAdminRole",
    "username" : "eksadminrole",
    "groups" : ["system:masters"]
  }
]

tags = {
  "SysName"      = "Naviteq"
  "SysOwner"     = "dmytro@naviteq.com"
  "Environment"  = "dev"
  "CostCenter"   = "2022"
  "BusinessUnit" = "Development"
  "Department"   = "Infrastructure"
  "user:tag"     = "aws-dev-es-cloud"
}

tenants = {
  "0" = {
    name                     = "dev"
    attach_worker_efs_policy = false

    instance_type        = "spot"
    spot_instance_pools  = 2
    asg_min_size         = 3
    asg_max_size         = 3
    asg_desired_capacity = 3
    kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=spot --node-labels=project=spot-messaging-group"

    tags = [
      {
        "key"                 = "user:tag"
        "propagate_at_launch" = "true"
        "value"               = "dev-pool"
      }
    ]
  }
}