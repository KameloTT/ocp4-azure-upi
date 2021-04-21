locals {
  master_subnet_cidr = "${cidrsubnet(var.machine_cidr, 3, 0)}" #master subnet is a smaller subnet within the vnet. i.e from /21 to /24
  node_subnet_cidr   = "${cidrsubnet(var.machine_cidr, 3, 1)}" #node subnet is a smaller subnet within the vnet. i.e from /21 to /24
  cluster_nr = "${split("-", "${var.cluster_id}")[length(split("-", "${var.cluster_id}")) - 1]}"
  cluster_domain = "${replace(var.cluster_id, "-${local.cluster_nr}", "")}.${var.base_domain}"
}

provider "azurerm" {
  subscription_id = "${var.azure_subscription_id}"
  client_id       = "${var.azure_client_id}"
  client_secret   = "${var.azure_client_secret}"
  tenant_id       = "${var.azure_tenant_id}"
}


module "vnet" {
  source              = "./vnet"
  vnet_name           = "${azurerm_virtual_network.cluster_vnet.name}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  master_subnet_cidr  = "${local.master_subnet_cidr}"
  node_subnet_cidr    = "${local.node_subnet_cidr}"
  cluster_id          = "${var.cluster_id}"
  region              = "${var.azure_region}"
  dns_label           = "${var.cluster_id}"

  # This is to create explicit dependency on private zone to exist before VMs are created in the vnet. https://github.com/MicrosoftDocs/azure-docs/issues/13728
  private_dns_zone_id = "${azurerm_dns_zone.private.id}"
}

module "dns" {
  source                          = "./dns"
  cluster_domain                  = "${local.cluster_domain}"
  base_domain                     = "${var.base_domain}"
  external_lb_fqdn                = "${module.vnet.public_lb_pip_fqdn}"
  internal_lb_ipaddress           = "${module.vnet.internal_lb_ip_address}"
  resource_group_name             = "${azurerm_resource_group.main.name}"
  base_domain_resource_group_name = "${var.azure_base_domain_resource_group_name}"
  private_dns_zone_name           = "${azurerm_dns_zone.private.name}"
  etcd_count                      = "${var.master_count}"
  etcd_ip_addresses               = "${module.master.ip_addresses}"
  
  private_dns_zone_id = "${azurerm_dns_zone.private.id}"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.cluster_id}-rg"
  location = "${var.azure_region}"
}

resource "azurerm_storage_account" "bootdiag" {
  name                     = "bootdiag${local.cluster_nr}"
  resource_group_name      = "${azurerm_resource_group.main.name}"
  location                 = "${var.azure_region}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_user_assigned_identity" "main" {
  name                = "identity${local.cluster_nr}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
}

resource "azurerm_role_assignment" "main" {
  scope                = "${azurerm_resource_group.main.id}"
  role_definition_name = "Contributor"
  principal_id         = "${azurerm_user_assigned_identity.main.principal_id}"
}

# https://github.com/MicrosoftDocs/azure-docs/issues/13728
resource "azurerm_dns_zone" "private" {
  name                           = "${local.cluster_domain}"
  resource_group_name            = "${azurerm_resource_group.main.name}"
  zone_type                      = "Private"
  resolution_virtual_network_ids = ["${azurerm_virtual_network.cluster_vnet.id}"]
}

resource "azurerm_virtual_network" "cluster_vnet" {
  name                = "${var.cluster_id}-vnet"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${var.azure_region}"
  address_space       = ["${var.machine_cidr}"]
}
