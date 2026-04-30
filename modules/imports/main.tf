terraform {
  required_providers {
    bpg = {
      source = "bpg/proxmox"
      version = "0.104.0"
    }
  }
}


### Only present if there is an "import" variable in the vm config in tfvars file
resource "proxmox_virtual_environment_download_file" "imported_disk" {
    provider                  = bpg
    for_each                  = var.import_disks
    content_type              = "import"
    datastore_id              = try(each.value.datastore, var.default_import.datastore, null)
    file_name                 = each.key
    node_name                 = try(each.value.node, var.default_import.node, null)
    url                       = try(each.value.url, null)
    checksum                  = try(each.value.checksum, null)
    checksum_algorithm        = try(each.value.checksum_algorithm, null)

}
