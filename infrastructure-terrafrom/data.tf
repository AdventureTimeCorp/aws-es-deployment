data "aws_partition" "current" {}

data "aws_iam_policy" "ssm" {
  arn = "arn:aws:iam::${data.aws_partition.current.partition}:policy/AmazonSSMManagedInstanceCore"
}

data "aws_eks_cluster" "cluster" {
  count = var.create_cluster ? 1 : 0
  name  = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.create_cluster ? 1 : 0
  name  = module.eks.cluster_id
}

data "aws_security_group" "default" {
  vpc_id = var.create_vpc ? module.vpc.vpc_id : var.vpc_id

  filter {
    name   = "group-name"
    values = ["default"]
  }
}

data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}


