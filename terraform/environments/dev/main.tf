terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. DÉFINITION (Pluriel/)
locals {
  project_name = "streambox"
  env          = "dev"
  location     = "France Central"
}

# 2. UTILISATION (Singulier - Regarde bien les "local.")

# Groupe de Ressources
module "rg" {
  source   = "../../modules/resource_group"
  # CORRECTION : local. (sans s)
  name     = "rg-${local.project_name}-${local.env}"
  location = local.location
}

# Azure Container Registry (ACR)
module "acr" {
  source              = "../../modules/acr"
  # CORRECTION : local. (sans s)
  name                = "acr${local.project_name}${local.env}001" 
  resource_group_name = module.rg.name
  location            = module.rg.location
}

# Cluster Kubernetes (AKS)
module "aks" {
  source              = "../../modules/aks"
  # CORRECTION : local. (sans s)
  cluster_name        = "aks-${local.project_name}-${local.env}"
  resource_group_name = module.rg.name
  location            = module.rg.location
  dns_prefix          = "${local.project_name}-${local.env}"
  node_count          = 1
}