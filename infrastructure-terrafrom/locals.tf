resource "random_string" "suffix" {
  length  = 4
  lower   = true
  upper   = false
  number  = false
  special = false
}

locals {
  default_security_group_id       = data.aws_security_group.default.id
  cluster_iam_role_name_to_create = "ServiceRoleForEKS${replace(title(var.platform_name), "-", "")}Cluster"
  worker_iam_role_name_to_create  = "ServiceRoleForEKS${replace(title(var.platform_name), "-", "")}WorkerNode"

  tenants_defaults = {
    # IAM resources defaults
    create_iam_kaniko        = false # Whether to create IAM role for Kaniko pod
    create_iam_worker_group  = false # Whether to create IAM role for worker group
    kaniko_role_name         = ""    # User defined Kaniko IAM role name to create
    worker_group_role_name   = ""    # User defined worker group IAM role name to create
    attach_worker_cni_policy = true  # Whether to attach the Amazon managed `AmazonEKS_CNI_Policy` IAM policy to the created worker IAM role
    attach_worker_efs_policy = true  # Whether to attach the Customer managed `EFSProvisionerPolicy` IAM policy to the created worker IAM role

    # worker groups launch templates defaults
    name                                     = "tenant-${random_string.suffix.result}"
    instance_type                            = "spot"
    override_instance_types                  = var.spot_instance_types                                              # A list of override instance types for mixed instances policy
    on_demand_percentage_above_base_capacity = 0                                                                    # Percentage split between on-demand and Spot instances above the base on-demand capacity
    spot_instance_pools                      = 2                                                                    # Number of Spot pools per availability zone to allocate capacity
    asg_min_size                             = 2                                                                    # Minimum worker capacity in the autoscaling group. Must be less or equal to desired_nodes_count
    asg_max_size                             = 2                                                                    # Maximum worker capacity in the autoscaling group
    asg_desired_capacity                     = 2                                                                    # Desired worker capacity in the autoscaling group
    subnets                                  = var.create_vpc ? module.vpc.private_subnets : var.private_subnets_id # A list of subnets to place the worker nodes in. i.e. ["subnet-123", "subnet-456", "subnet-789"]
    additional_userdata                      = var.add_userdata                                                     # Userdata to append to the default userdata
    kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=spot"                    # This string is passed directly to kubelet if set. Useful for adding labels or taints
    suspended_processes                      = []                                                                   # A list of processes to suspend, i.e. ["AZRebalance", "HealthCheck", "ReplaceUnhealthy"]
    public_ip                                = false                                                                # Associate a public ip address with a worker
    root_volume_size                         = 30                                                                   # Root volume size of workers instances
    enable_monitoring                        = false                                                                # Enables/disables detailed monitoring
    key_name                                 = var.key_name                                                         # The key pair name that should be used for the instances in the autoscaling group
    iam_instance_profile_name                = var.worker_iam_instance_profile_name                                 # A custom IAM instance profile name. Can be used when manage_worker_iam_resources is set to false
    iam_role_id                              = ""                                                                   # A custom IAM role id. Can be used when manage_worker_iam_resources is set to true
    metadata_http_endpoint                   = "enabled"                                                            # The state of the metadata service: enabled, disabled.
    metadata_http_tokens                     = "optional"                                                           # If session tokens are required: optional, required.
    metadata_http_put_response_hop_limit     = 2                                                                    # The desired HTTP PUT response hop limit for instance metadata requests.
    tags                                     = []                                                                   # A list of maps defining extra tags to be applied to the worker group autoscaling group, volumes and ENIs
    # target_group_arns                        = module.nlb_kubernetes.target_group_arns                              # A list of LoadBalancer target group ARNs to be associated to the autoscaling group
    additional_security_group_ids            = aws_security_group.kunernetes_nodes.id                               # A list of additional security group ids to include in worker launch config
  }

  worker_groups_launch_template_tenants = [for key in keys(var.tenants) :
    {
      name = "${lookup(var.tenants[key], "name", local.tenants_defaults["name"])}-${lookup(var.tenants[key], "instance_type", local.tenants_defaults["instance_type"])}"
      override_instance_types = lookup(
        var.tenants[key],
        "override_instance_types",
        lookup(var.tenants[key], "instance_type", local.tenants_defaults["instance_type"]) == "spot" ? var.spot_instance_types
        : (lookup(var.tenants[key], "instance_type", local.tenants_defaults["instance_type"]) == "on-demand" ? var.demand_instance_types
          : local.tenants_defaults["override_instance_types"]
        )
      )
      on_demand_percentage_above_base_capacity = lookup(
        var.tenants[key],
        "on_demand_percentage_above_base_capacity",
        lookup(var.tenants[key], "instance_type", local.tenants_defaults["instance_type"]) == "spot" ? 0
        : (lookup(var.tenants[key], "instance_type", local.tenants_defaults["instance_type"]) == "on-demand" ? 100
          : local.tenants_defaults["on_demand_percentage_above_base_capacity"]
        )
      )
      spot_instance_pools  = lookup(var.tenants[key], "spot_instance_pools", local.tenants_defaults["spot_instance_pools"])
      asg_min_size         = lookup(var.tenants[key], "asg_min_size", local.tenants_defaults["asg_min_size"])
      asg_max_size         = lookup(var.tenants[key], "asg_max_size", local.tenants_defaults["asg_max_size"])
      asg_desired_capacity = lookup(var.tenants[key], "asg_desired_capacity", local.tenants_defaults["asg_desired_capacity"])
      subnets              = lookup(var.tenants[key], "subnets", local.tenants_defaults["subnets"])
      additional_userdata  = lookup(var.tenants[key], "additional_userdata", local.tenants_defaults["additional_userdata"])
      kubelet_extra_args = lookup(
        var.tenants[key],
        "kubelet_extra_args",
        "--node-labels=node.kubernetes.io/lifecycle=${lookup(var.tenants[key], "instance_type", local.tenants_defaults["instance_type"]) == "on-demand" ? "normal" : "spot"} --node-labels=project=${lookup(var.tenants[key], "name", local.tenants_defaults["name"])} --register-with-taints=project=${lookup(var.tenants[key], "name", local.tenants_defaults["name"])}:NoSchedule"
      )
      suspended_processes = lookup(var.tenants[key], "suspended_processes", local.tenants_defaults["suspended_processes"])
      public_ip           = lookup(var.tenants[key], "public_ip", local.tenants_defaults["public_ip"])
      root_volume_size    = lookup(var.tenants[key], "root_volume_size", local.tenants_defaults["root_volume_size"])
      enable_monitoring   = lookup(var.tenants[key], "enable_monitoring", local.tenants_defaults["enable_monitoring"])
      key_name            = lookup(var.tenants[key], "key_name", local.tenants_defaults["key_name"])
      iam_instance_profile_name =  local.tenants_defaults["iam_instance_profile_name"]
      iam_role_id = ""
      metadata_http_endpoint               = lookup(var.tenants[key], "metadata_http_endpoint", local.tenants_defaults["metadata_http_endpoint"])
      metadata_http_tokens                 = lookup(var.tenants[key], "metadata_http_tokens", local.tenants_defaults["metadata_http_tokens"])
      metadata_http_put_response_hop_limit = lookup(var.tenants[key], "metadata_http_put_response_hop_limit", local.tenants_defaults["metadata_http_put_response_hop_limit"])
      tags                                 = lookup(var.tenants[key], "tags", [])
      # target_group_arns                    = lookup(var.tenants[key], "target_group_arns", local.tenants_defaults["target_group_arns"])
      additional_security_group_ids        = lookup(var.tenants[key], "additional_security_group_ids", local.tenants_defaults["additional_security_group_ids"])
    }
  ]

}
