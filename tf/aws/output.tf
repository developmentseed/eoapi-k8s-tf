output "vpc_config" {
  description = "the VPC default SG for all nodes"
  value = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}