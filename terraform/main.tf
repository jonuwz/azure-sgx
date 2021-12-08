variable "location" { default = "eastus2" }
variable "prefix" { default = "sgx" }
variable "node_count" { default = 1 }

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "rg" {
    name     = "rg"
    location = "${var.location}"
}

