terraform {
  required_version = ">= 1.3.2"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">= 2.9.11"
    }
  }
}

variable "proxmox_api_password" {
  type      = string
  sensitive = true
}

variable "proxmox_api_user" {
  type = string
}

variable "proxmox_host" {
  type = string
}

variable "proxmox_node" {
  type = string
}

provider "proxmox" {
  pm_api_url      = "https://${var.proxmox_host}/api2/json"
  pm_user         = var.proxmox_api_user
  pm_password     = var.proxmox_api_password
  pm_tls_insecure = true
  pm_parallel     = 2
}

# Base infra nodes
module "base-infra" {
  source = "./envs/prod/base-infra"

  providers = {
    proxmox = proxmox
  }
}

# Jamlab-ansible provisioned nodes
module "jamlab-ansible" {
  source = "./envs/jamlab-ansible"

  providers = {
    proxmox = proxmox
  }
}