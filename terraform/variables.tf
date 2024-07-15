variable "iam_cluster_role_name" {
  description = "EKS Cluster role name for IAM ROLE"
  type        = string
  default = "eks-cluster-role"
}

variable "iam_node_group_role_name" {
  description = "EKS Cluster role name for IAM ROLE"
  type        = string
  default = "eks-node-group-role"
}

variable "vpc_tag_name" {
  description = "VPC Tag Name"
  type        = string
  default = "eks-vpc"
}

variable "vpc_cidr_block_region1" {
  description = "VPC CIDR block range"
  type        = string
  default = "10.0.0.0/16"
}

variable "vpc_cidr_block_region2" {
  description = "VPC CIDR block range"
  type        = string
  default = "10.1.0.0/16"
}

variable "subnet_cidr_blocks_region1" {
  description = "List of CIDR blocks for the subnets"
  type        = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "subnet_cidr_blocks_region2" {
  description = "List of CIDR blocks for the US subnets"
  type        = list(string)
  default = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
}

variable "igw_tag_name" {
  description = "Tag name for Internet gateway"
  type        = string
  default = "eks-igw"
}

variable "subnet_tag_name" {
  description = "Tag name for Subnets"
  type        = string
  default = "eks-public-subnet"
}

variable "route_tag_name_region1" {
  description = "Tag name for Subnet Route Table"
  type        = string
  default = "eks-public-route-table-region1"
}

variable "route_tag_name_region2" {
  description = "Tag name for Subnet Route Table"
  type        = string
  default = "eks-public-route-table-region2"
}

variable "eks_cluster_name" {
  description = "EKS Cluster name"
  type        = string
  default = "lms-cluster"
}

variable "eks_cluster_node_group_name" {
  description = "EKS Cluster name"
  type        = string
  default = "standard-workers"
}

variable "node_instance_type" {
  description = "EKS Cluster Node instance type"
  type        = list(string)
  default = ["t3a.small", "t3a.small", "t3a.small", "t3a.small"]
}

variable "node_desired_size" {
  description = "EKS worker node Desired size"
  type = number
  default = 5
}

variable "node_min_size" {
  description = "EKS worker node min size"
  type = number
  default = 5
}

variable "node_max_size" {
  description = "EKS worker node max size"
  type = number
  default = 12
}

variable "node_disk_size" {
  description = "EKS worker node disk size"
  type = number
  default = 25
}