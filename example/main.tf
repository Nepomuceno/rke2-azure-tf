

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rke2" {
  name     = "sample-rke2-rg"
  location = "usgovvirginia"
}

resource "azurerm_virtual_network" "rke2" {
  name          = "sample-rke2-vnet"
  address_space = ["10.0.0.0/16"]

  resource_group_name = azurerm_resource_group.rke2.name
  location            = azurerm_resource_group.rke2.location
}

resource "azurerm_subnet" "rke2" {
  name = "sample-rke2-snet"

  resource_group_name  = azurerm_resource_group.rke2.name
  virtual_network_name = azurerm_virtual_network.rke2.name

  address_prefixes = ["10.0.1.0/24"]
}


module "rke2" {
  source                 = "../"
  server_public_ip       = true
  cluster_name           = "samplerke"
  subnet_id              = azurerm_subnet.rke2.id
  server_open_ssh_public = true
}
