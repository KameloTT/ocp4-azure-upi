output "cluster-pip" {
  value = "${azurerm_public_ip.cluster_public_ip.ip_address}"
}

output "public_subnet_id" {
  value = "${local.subnet_ids}"
}
output "node_subnet_ids" {
  value = "${local.node_subnet_ids}"
}


output "master_nsg_name" {
  value = "${azurerm_network_security_group.master.name}"
}
