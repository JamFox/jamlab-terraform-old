terraform {
  required_version = ">= 1.3.2"
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = ">= 2.9.11"
    }
  }
}

provider "proxmox" {
    pm_api_url = var.proxmox_api_url
    pm_user = var.proxmox_user
    pm_password = var.proxmox_pass
    pm_tls_insecure = var.proxmox_ignore_tls
    pm_parallel = var.proxmox_parallel
}

# Base infra nodes
module "base-infra" {
  source = "./envs/prod/base-infra"

  providers = {
    proxmox = proxmox
  }  
}
