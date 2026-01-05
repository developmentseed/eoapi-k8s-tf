resource "aws_efs_file_system" "efs" {
  count          = var.enable_efs ? 1: 0
  creation_token = "${var.cluster_name}-efs"
}

resource "aws_efs_mount_target" "efs" {
  for_each         = var.enable_efs ? toset(data.aws_subnets.default.ids) : toset([])
  file_system_id   = aws_efs_file_system.efs[0].id
  subnet_id        = each.value
  security_groups  = [aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id]
}

output "nfs_server_dns" {
  value = aws_efs_file_system.efs[0].dns_name
}