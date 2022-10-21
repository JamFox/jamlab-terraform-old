terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = ">= 2.9.11"    
    }
  }
}

# Common variables
locals {
  desc = "VM from jamlab-terraform on ${timestamp()}"
  default_target_node    = "pve0"
  full_clone             = true
  onboot       = true
  gateway      = "192.168.0.1"
  cidr         = "/24"
  nameserver   = "192.168.0.1"
  searchdomain = "jamfox.dev"

  # Default flavor
  default_clone      = "debian11"
  default_vm_memory  = "31744"
  default_vm_sockets = 2
  default_vm_cores   = 2
  
  # Network
  vm_network = [
    {
      model  = "virtio"
      bridge = "vmbr0"
      tag    = null
    },
  ]

  # Disks. First is OS, size should be >= template.
  vm_disk = [
    {
      type    = "scsi"
      storage = "local-lvm"
      size    = "200G"
      format  = "raw"
      ssd     = 0
    },         
  ]  

  # Connection details
  qemu_agent_enabled     = 1
  default_image_username = "root"
  default_image_password = "packer"
  default_ssh_prvkey     = tls_private_key.bootstrap_private_key.private_key_pem
  default_ssh_pubkey     = tls_private_key.bootstrap_private_key.public_key_openssh
}

variable "vms" {
  description = "Base Infrastructure Virtual Machines"
  type = map
  default = {
  vm0 = {
        name = "vb0"
        ip   = "192.168.0.120"
    }
  vm1 = {
        name = "vb1"
        ip   = "192.168.0.121"
  }
 }
}


module "vm" {
  for_each = var.vms
  source = "../../../modules/pve-vm" 

  target_node = local.default_target_node
  clone = local.default_clone
  vm_name = each.value.name
  desc = local.desc

  sockets = local.default_vm_sockets
  cores = local.default_vm_cores
  memory = local.default_vm_memory

  onboot = local.onboot
  full_clone = local.full_clone

  nameserver = local.nameserver
  vm_network = local.vm_network
  searchdomain = local.searchdomain
  ipconfig0 = "ip=${each.value.ip}${local.cidr},gw=${local.gateway}"
  ip_address = "${each.value.ip}"

  vm_disk = local.vm_disk 

  agent = local.qemu_agent_enabled
  
  default_image_username = local.default_image_username
  default_image_password = local.default_image_password
  private_key = local.default_ssh_prvkey
  ssh_public_keys = local.default_ssh_pubkey
}

resource "tls_private_key" "bootstrap_private_key" {
  algorithm = "RSA"
}
resource "local_file" "temp-private-key" {
  sensitive_content = tls_private_key.bootstrap_private_key.private_key_pem
  filename = "${path.module}/private_key.pem"
  file_permission = "0600"
}