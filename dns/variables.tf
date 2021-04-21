variable "cluster_domain" {
  description = "The domain for the cluster that all DNS records must belong"
  type        = "string"
}

variable "base_domain" {
  description = "The base domain used for public records"
  type        = "string"
}

variable "base_domain_resource_group_name" {
  description = "The resource group where the base domain is"
  type        = "string"
}


variable "private_dns_zone_name" {
  description = "private DNS zone name that should be used for records"
  type        = "string"
}


variable "resource_group_name" {
  type        = "string"
  description = "Resource group for the deployment"
}

variable "private_dns_zone_id" {
  type        = "string"
  description = "This is to create explicit dependency on private zone to exist before VMs are created in the vnet. https://github.com/MicrosoftDocs/azure-docs/issues/13728"
}
