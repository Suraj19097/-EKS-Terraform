output "cluster_id" {
  value = aws_eks_cluster.My.id
}

output "node_group_id" {
  value = aws_eks_node_group.My.id
}

output "vpc_id" {
  value = aws_vpc.My_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.My_subnet[*].id
}

