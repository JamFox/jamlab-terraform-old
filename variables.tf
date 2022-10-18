variable "proxmox_api_url" {
    description = "Proxmox API endpoint"
    type = string
    default = "https://sol.jamfox.dev:8006/api2/json"
}
variable "proxmox_api_user" {
    description = "Proxmox API user. Needs PVEDatastoreUser, PVEVMAdmin, PVETemplateUser permissions"
    type = string
    sensitive = true
    default = "terraform-prov@pve"
}
variable "proxmox_api_pass" {
    description = "API user password. Alternatively use environment variable TF_VAR_proxmox_api_pass"
    sensitive = true
}
variable "proxmox_ignore_tls" {
    description = "Disable TLS verification while connecting"
    type = string
    default = "false"
}
