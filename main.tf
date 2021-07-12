terraform {
  required_providers {
    azurerm = {
      version = "~>2.66.0"
      source  = "hashicorp/azurerm"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>3.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  tags = {
    "Environment" = var.cluster_name,
    "Terraform"   = "true",
  }
}

resource "azurerm_resource_group" "rke2" {
  name     = var.cluster_name
  location = var.location
}

resource "azurerm_virtual_network" "rke2" {
  name          = "${var.cluster_name}-vnet"
  address_space = ["10.0.0.0/16"]

  resource_group_name = azurerm_resource_group.rke2.name
  location            = azurerm_resource_group.rke2.location

  tags = local.tags
}

resource "azurerm_subnet" "rke2" {
  name = "${var.cluster_name}-snet"

  resource_group_name  = azurerm_resource_group.rke2.name
  virtual_network_name = azurerm_virtual_network.rke2.name

  address_prefixes = ["10.0.1.0/24"]
}

module "rke2_cluster" {
  source              = "./modules/rke2-cluster"
  cluster_name        = var.cluster_name
  resource_group_name = azurerm_resource_group.rke2.name
  vnet_id             = azurerm_virtual_network.rke2.id
  subnet_id           = azurerm_subnet.rke2.id
  vnet_name           = azurerm_virtual_network.rke2.name
  subnet_name         = azurerm_subnet.rke2.name
  service_principal   = var.service_principal
  cloud               = var.cloud
  tags                = local.tags

  server_public_ip      = var.server_public_ip
  vm_size               = var.vm_size
  server_instance_count = var.server_instance_count
  agent_instance_count  = var.agent_instance_count

  depends_on = [
    azurerm_resource_group.rke2
  ]
}
