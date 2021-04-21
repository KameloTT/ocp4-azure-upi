# Canonical internal state definitions for this module.
# read only: only locals and data source definitions allowed. No resources or module blocks in this file

// Only reference data sources which are guaranteed to exist at any time (above) in this locals{} block
locals {
  subnet_ids = "${azurerm_subnet.master_subnet.id}"

  node_subnet_ids = "${azurerm_subnet.node_subnet.id}"

}

