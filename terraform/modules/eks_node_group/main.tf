terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Specify the required provider version
    }
  }
}

# Launch Template
# resource "aws_launch_template" "this" {
#   name          = "${var.node_group_name}-launch-template"
#   image_id      = var.node_group_name == "standard-workers-region1" ? "ami-0b99cb694537c9075" : "ami-0c2d8d65bc57661b5"
#   user_data = filebase64("${path.module}/userdata.sh")

#   block_device_mappings {
#     device_name = "/dev/xvda"
#     ebs {
#       volume_size = var.node_disk_size
#     }
#   }
# }

# Create the EKS Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.node_cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.node_group_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  # launch_template {
  #   id      = aws_launch_template.this.id
  #   version = "$Latest"
  # }

  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size, 
      instance_types, 
      disk_size
    ]
  }
}