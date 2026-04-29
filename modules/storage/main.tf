terraform {
  required_providers {
    bpg = {
      source = "bpg/proxmox"
      version = "0.104.0"
    }
  }
}



resource "proxmox_storage_cifs" "cifs_storage" {
  provider                 = bpg
  for_each                 = var.custom_cifs
  id                       = each.key
  server                   = try(each.value.server, var.default_cifs.server, null)
  share                    = try(each.value.share, var.default_cifs.share, null)

  username                 = try(each.value.username, var.default_cifs.username, null)
  password                 = var.cifs_password

  content                  = try(each.value.content_types, var.default_cifs.content_types, null)
  domain                   = try(each.value.domain, var.default_cifs.domain, null)
  subdirectory             = try(each.value.subdirectory, var.default_cifs.subdirectory, null)
  preallocation            = try(each.value.preallocation, var.default_cifs.preallocation, null)
  snapshot_as_volume_chain = true
}