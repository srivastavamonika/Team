terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.35.0"
    }
  }
  backend "azurerm" {

  }
}

provider "azurerm" {
  features {

  }
  subscription_id = "e7b0406b-0a7e-4b24-929a-20417273d58e"
}