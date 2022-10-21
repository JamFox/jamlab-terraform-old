variable "vm_name" {
    description = "Proxmox VM name"
    type = string
}

variable "target_node" {
    description = "Target Proxmox node"
    type = string
}

variable "clone" {
    description = "Name of VM to clone"
    type = string
}

variable "full_clone" {
    description = "true to create a full clone, false to create a linked clone"
    type = bool
    default = true    
}

variable "desc" {
    description = "Proxmox VM description"
    type = string
    default = "jamlab-terraform pve-vm"
}

variable "sockets" {
    description = "The number of CPU sockets to allocate to the VM."
    type = number
    default = 1
}

variable "cores" {
    description = "The number of CPU cores per CPU socket to allocate to the VM."
    type = number
    default = 1
}

variable "memory" {
    description = "Amount of RAM to assign to the container in MB."
    type = string
    default = "1024"
}

variable "vm_network" {
    description = "Specify network devices"
    type = list(object({
        model     = string
        bridge    = string
        tag       = number
    }))
    default = [
        {
        model     = "virtio"
        bridge    = "vmbr0"
        tag       = null
        }
    ]
}

variable "vm_disk" {
    description = "Specify disk variables"
    type = list(object({
        type        = string
        storage     = string
        size        = string
        format      = string
        ssd         = number
    }))
    default = [
        {
        type        = "scsi"
        storage     = "vm-store"
        size        = "40G"
        format      = "raw"
        ssd         = 0
        }
    ]
}

variable "onboot" {
    description = "true to start on boot, false to not"
    type = bool
    default = true
}

variable "ipconfig0" {
    description = "The first IP address to assign to the guest"
    type = string
}

variable "ip_address" {
    description = "VM IP address"
    type = string
}

variable "nameserver" {
    description = "IP to use as DNS"
    type = string
    default = "CHANGEME"
}

variable "searchdomain" {
    description = "Sets the DNS search domains for the container"
    type = string
    default = "jamfox.dev"
}

variable "boot" {
    description = "VM boot order. The Telmate provider has a bug, this module implements the workaround. Ref: https://github.com/Telmate/terraform-provider-proxmox/issues/282."
    type = string
    default = "order=virtio0;ide2;net0"
}

variable "agent" {
    description = "1 enables QEMU Guest Agent, 0 disables. Must run the qemu-guest-agent daemon in the quest for this to have any effect."
    type = number
    default = 1    
}

variable "ssh_public_keys" {
    description = "Temp SSH public key that will be added to the container"
    type = string
}

variable "private_key" {
    description = "Temp SSH private key for provisioning"
    type = string
}

variable "default_image_username" {
    description = "Username baked into template image, used for initial connection for configuration"
    type = string
}

variable "default_image_password" {
    description = "Password for default user baked into template image, used for initial connection for configuration"
    type = string
    default = ""
}

variable "provisioner_type" {
    description = "Connection type that should be used by Terraform. Valid types are ssh and winrm"
    type = string
    default = "ssh"
}

variable "target_platform" {
    description = "Target platform Terraform provisioner connects to. Valid values are windows and unix"
    type = string
    default = "unix"
}

variable "serial" {
  description = "Create a serial device inside the VM. Serial interface of type socket is used by xterm.js. Using a serial device as terminal"
  type = object({
    id   = number
    type = string
  })
  default = {
    id   = 0
    type = "socket"
  }
}