terraform {
    backend "s3" {
    endpoints = {
      s3 = "https://s3.eu-central-003.backblazeb2.com"
    }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    region                      = "eu-central-003"
    bucket                      = "bb-eu-s3-private-terraform"
    key                         = "actions-test/terraform.tfstate"
  }
  required_providers {
    telmate = {
      source = "telmate/proxmox"
      version = "3.0.2-rc05"
    }
    bpg = {
      source = "bpg/proxmox"
      version = "0.98.1"
    }
  }
}


module "proxmox_import" {
  source           = "./modules/imports"
  import_disks          = var.import_disks
  default_import        = var.default_import
}


module "proxmox_template" {
  source           = "./modules/templates"
  custom_templates          = var.custom_templates
  default_templates = var.default_templates
  imported_disk     = module.proxmox_import.out_import_id
}


module "proxmox_vm" {
  source           = "./modules/vms-bpg"
  iso_vms          = var.iso_vms
  default_vm       = var.default_vm
  template_id      = module.proxmox_template.out_template_id

}


module "proxmox_vm_flatcar" {
  source           = "./modules/flatcar"

}