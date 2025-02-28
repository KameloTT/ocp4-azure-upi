locals {
  public_lb_frontend_ip_configuration_name = "public-lb-ip"
}

resource "azurerm_public_ip" "cluster_public_ip" {
  sku                 = "Standard"
  location            = "${var.region}"
  name                = "${var.cluster_id}-pip"
  resource_group_name = "${var.resource_group_name}"
  allocation_method   = "Static"
  domain_name_label   = "${var.dns_label}"
}

data "azurerm_public_ip" "cluster_public_ip" {
  name                = "${azurerm_public_ip.cluster_public_ip.name}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_lb" "public" {
  sku                 = "Standard"
  name                = "${var.cluster_id}-public-lb"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.region}"

  frontend_ip_configuration {
    name                 = "${local.public_lb_frontend_ip_configuration_name}"
    public_ip_address_id = "${azurerm_public_ip.cluster_public_ip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "master_public_lb_pool" {
  loadbalancer_id     = "${azurerm_lb.public.id}"
  name                = "${var.cluster_id}-public-lb-control-plane"
}

resource "azurerm_lb_rule" "public_lb_rule_api_internal" {
  name                           = "api-internal"
  resource_group_name            = "${var.resource_group_name}"
  protocol                       = "Tcp"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.master_public_lb_pool.id}"
  loadbalancer_id                = "${azurerm_lb.public.id}"
  frontend_port                  = 6443
  backend_port                   = 6443
  frontend_ip_configuration_name = "${local.public_lb_frontend_ip_configuration_name}"
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 30
  load_distribution              = "Default"
  probe_id                       = "${azurerm_lb_probe.public_lb_probe_api_internal.id}"
}

resource "azurerm_lb_rule" "public_lb_rule_sint_internal" {
  name                           = "sint-internal"
  resource_group_name            = "${var.resource_group_name}"
  protocol                       = "Tcp"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.master_public_lb_pool.id}"
  loadbalancer_id                = "${azurerm_lb.public.id}"
  frontend_port                  = 22623
  backend_port                   = 22623
  frontend_ip_configuration_name = "${local.public_lb_frontend_ip_configuration_name}"
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 30
  load_distribution              = "Default"
  probe_id                       = "${azurerm_lb_probe.public_lb_sint.id}"
}

resource "azurerm_lb_probe" "public_lb_probe_api_internal" {
  name                = "api-internal-probe"
  resource_group_name = "${var.resource_group_name}"
  interval_in_seconds = 10
  number_of_probes    = 3
  loadbalancer_id     = "${azurerm_lb.public.id}"
  port                = 6443
  protocol            = "TCP"
}

resource "azurerm_lb_probe" "public_lb_sint" {
  name                = "sint-probe"
  resource_group_name = "${var.resource_group_name}"
  interval_in_seconds = 10
  number_of_probes    = 3
  loadbalancer_id     = "${azurerm_lb.public.id}"
  port                = 22623
  protocol            = "TCP"
}

resource "azurerm_lb_backend_address_pool" "worker_public_lb_pool" {
  loadbalancer_id     = "${azurerm_lb.public.id}"
  name                = "${var.cluster_id}-public-lb-routers"
}

resource "azurerm_lb_rule" "public_lb_rule_http" {
  name                           = "tcp-80"
  resource_group_name            = "${var.resource_group_name}"
  protocol                       = "Tcp"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.worker_public_lb_pool.id}"
  loadbalancer_id                = "${azurerm_lb.public.id}"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${local.public_lb_frontend_ip_configuration_name}"
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 30
  load_distribution              = "Default"
  probe_id                       = "${azurerm_lb_probe.public_lb_http.id}"
}

resource "azurerm_lb_rule" "public_lb_rule_https" {
  name                           = "tcp-443"
  resource_group_name            = "${var.resource_group_name}"
  protocol                       = "Tcp"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.worker_public_lb_pool.id}"
  loadbalancer_id                = "${azurerm_lb.public.id}"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${local.public_lb_frontend_ip_configuration_name}"
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 30
  load_distribution              = "Default"
  probe_id                       = "${azurerm_lb_probe.public_lb_http.id}"
}

resource "azurerm_lb_probe" "public_lb_http" {
  name                = "probe-http"
  resource_group_name = "${var.resource_group_name}"
  interval_in_seconds = 10
  number_of_probes    = 3
  loadbalancer_id     = "${azurerm_lb.public.id}"
  port                = 80
  protocol            = "TCP"
}
