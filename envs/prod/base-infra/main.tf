terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = ">= 2.9.11"    
    }
  }
}

# Set variables for provisioning 
locals {
  desc = "Base infra VM, created with Terraform on ${timestamp()}"
  full_clone = true
  default_image_username = "CHANGEME"
  default_image_password = "CHANGEME"
  clone_wait = 5
  vm_sockets = 2
  vm_cores = 2  
  onboot = true
  nameserver = "192.168.0.100"
  searchdomain = "jamfox.dev"

  vm_network = [
    {
      model = "virtio"
      bridge = "vmbr0"
      tag = null
    },
  ]

  # Dynamic block for VM disk devices. First is OS, size should be >= template.
  vm_disk = [
    {
      type = "scsi"
      storage = "vm-store"
      size = "50G"
      format = "qcow2"
      ssd = 0
    },         
  ]  
  boot = "order=scsi0;ide2;net0"
  agent = 1
  ssh_public_keys = tls_private_key.bootstrap_private_key.public_key_openssh
  terraform_provisioner_type = "CHANGEME"
  provisioner_target_platform = "CHANGEME"
  ansible_inventory_filename = "active_directory"

  # Primary node
  pdc_target_node = "CHANGEME"
  pdc_clone = "CHANGEME" 
  pdc_vm_name = "CHANGEME"
  pdc_vm_memory = "2048"
  pdc_ip_address = "CHANGEME"
  pdc_ip_cidr = "/24"
  pdc_gw = "CHANGEME"
  pdc_ansible_inventory_group = "primary_dc"
  
  # Secondary node
  sdc_target_node = "CHANGEME"
  sdc_clone = "CHANGEME" 
  sdc_vm_name_prefix = "dc"
  sdc_vm_memory = "2048"
  # IP assignment count in this block will control count of secondary DC VMs provisioned
  sdc_ip_addresses = {
      "1" = "CHANGEME"
  }
  sdc_ip_cidr = "/24"
  sdc_gw = "CHANGEME"
  sdc_ansible_inventory_group = "CHANGEME"
}

# Primary node creation module 
module "pdc_vm" {
  source = "../../../modules/pve-vm" 

  target_node = local.pdc_target_node
  clone = local.pdc_clone
  vm_name = local.pdc_vm_name
  desc = local.desc
  sockets = local.vm_sockets
  cores = local.vm_cores   
  memory = local.pdc_vm_memory
  onboot = local.onboot
  full_clone = local.full_clone
  clone_wait = local.clone_wait
  nameserver = local.nameserver
  vm_network = local.vm_network
  vm_disk = local.vm_disk  
  searchdomain = local.searchdomain
  boot = local.boot
  agent = local.agent
  ipconfig0 = "ip=${local.pdc_ip_address}${local.pdc_ip_cidr},gw=${local.pdc_gw}"
  ip_address = local.pdc_ip_address
  ssh_public_keys = local.ssh_public_keys
  default_image_username = local.default_image_username
  default_image_password = local.default_image_password
  provisioner_type = local.terraform_provisioner_type
  target_platform = local.provisioner_target_platform
  private_key = tls_private_key.bootstrap_private_key.private_key_pem
}

# Secondary node creation module 
module "sdc_vms" {
  source = "../../../modules/pve-vm"
    
  count = length(local.sdc_ip_addresses)

  target_node = local.sdc_target_node
  clone = local.sdc_clone
  vm_name = "${local.sdc_vm_name_prefix}${format("%02d", count.index+2)}"
  desc = local.desc
  sockets = local.vm_sockets
  cores = local.vm_cores   
  memory = local.sdc_vm_memory
  onboot = local.onboot
  full_clone = local.full_clone
  clone_wait = local.clone_wait
  nameserver = local.nameserver
  vm_network = local.vm_network
  vm_disk = local.vm_disk  
  searchdomain = local.searchdomain
  boot = local.boot
  agent = local.agent
  ipconfig0 = "ip=${lookup(local.sdc_ip_addresses, count.index+1)}${local.sdc_ip_cidr},gw=${local.sdc_gw}"
  ip_address = lookup(local.sdc_ip_addresses, count.index+1)
  ssh_public_keys = local.ssh_public_keys
  default_image_username = local.default_image_username
  default_image_password = local.default_image_password
  provisioner_type = local.terraform_provisioner_type
  target_platform = local.provisioner_target_platform  
  private_key = tls_private_key.bootstrap_private_key.private_key_pem
}

resource "null_resource" "configuration" {
  depends_on = [
    module.pdc_vm,
    module.sdc_vms,
    module.ansible_inventory
  ]

  # Update jamlab-ansible hosts
  provisioner "local-exec" {
    command = "../../../bin/jamlab-ansible-hostadd"
  }
}
