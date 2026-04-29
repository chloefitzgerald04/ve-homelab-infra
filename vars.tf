variable "ssh_key" {
  default = "your_public_ssh_key_here"
}
variable "proxmox_host" {
    default = "pve3"
}
variable "iso" {
    default = "NAS:iso/archlinux-2024.06.01-x86_64.iso"
}
variable "nic_name" {
    default = "vmbr2"
}
variable "vlan_num" {
    default = "10"
}
variable "mem" {
    default = "4096"
}

variable "api_url" {
    default = "https://10.0.0.101:8006/api2/json"
}
variable "token_secret" {
    default = "123abc"
}
variable "token_id" {
    default = "test@pve!test"
}

variable "iso_vms" {
    default = {}
}
variable "default_vm" {
    default = {}
}

variable "custom_templates" {
    default = {}
}

variable "default_templates" {
    default = {}
}

variable "import_disks" {
    default = {}
}
variable "default_import" {
    default = {}
}

variable "imported_disk" {
    default = {}
}

variable "flatcar_vms" {
    default = {}
}

variable "default_flatcar" {
    default = {}
}


variable "traefik_env" {
  sensitive  = true
  default = ""
}
variable "zabbix_env" {
  sensitive  = true
  default = ""
}

variable "homelabv2_secret" {
  sensitive   = true
  default     = ""
}

variable "share_password" {
  sensitive   = true
  default     = ""
}