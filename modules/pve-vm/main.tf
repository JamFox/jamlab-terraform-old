terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = ">= 2.9.11"    
    }
  }
}

resource "proxmox_vm_qemu" "qemu_vm" {
    name = var.vm_name
    target_node = var.target_node
    clone = var.clone
    full_clone = var.full_clone
    clone_wait = var.clone_wait
    boot = var.boot
    agent = var.agent
    sockets = var.sockets
    cores = var.cores
    memory = var.memory
    desc = var.desc
    nameserver = var.nameserver
    searchdomain = var.searchdomain
    dynamic "network" {
      for_each = var.vm_network
      content {
        model     = network.value.model
        bridge    = network.value.bridge
        tag       = network.value.tag
      }
    }
    dynamic "disk" {
      for_each = var.vm_disk
      content {
        type       = disk.value.type
        storage    = disk.value.storage
        size       = disk.value.size
        format     = disk.value.format
        ssd        = disk.value.ssd
      }
    }

    ipconfig0 = var.ipconfig0    
    sshkeys = var.ssh_public_keys
    ciuser = var.default_image_username
    cipassword = var.default_image_password
}

# Wait for provisioning
resource "time_sleep" "wait_180_sec" {
  depends_on = [proxmox_vm_qemu.qemu_vm]
  create_duration = "180s"
}
