terraform {
  required_providers {
    telmate = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
    }
  }
}

locals {
  vm_index = { for idx, key in keys(var.flatcar_vms) : key => idx }
}

resource "proxmox_cloud_init_disk" "ci" {
  provider = telmate
  for_each = {for k, v in var.flatcar_vms : k => v if !lookup(v, "disabled", false)}
  name      = "cf-pve-cl-02-flatcar-${local.vm_index[each.key] + 1}"
  pve_node  = each.value.node
  storage   = "ve-nas-01"

  meta_data = yamlencode({
    instance_id    = sha1("cf-pve-cl-02-flatcar-${local.vm_index[each.key] + 1}")
    local-hostname = "cf-pve-cl-02-flatcar-${local.vm_index[each.key] + 1}"
  })

  user_data = data.ct_config.ignition_json[each.key].rendered
  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "proxmox_vm_qemu" "flatcar_vm" {
  provider                      = telmate
  clone_id                      = var.template_id.id["flatcar-template"]
  full_clone                    = true
  clone_wait                    = 0
  for_each                      = {for k, v in var.flatcar_vms : k => v if !lookup(v, "disabled", false)}

  automatic_reboot              = try(each.value.reboot_after_update, var.default_flatcar.reboot_after_update, null)
  automatic_reboot_severity     = try(each.value.automatic_reboot_severity, var.default_flatcar.automatic_reboot_severity, null)

  name                          = each.key
  target_node                   = try(each.value.node, var.default_flatcar.node, null)
  #description                   = "data:application/vnd.coreos.ignition+json;charset=UTF-8;base64,${base64encode(data.ct_config.ignition_json[each.key].rendered)}"

  agent                         = 1
  define_connection_info        = false 
  bios                          = "seabios" 
  os_type                       = "host"
  boot                          = try(each.value.boot_order, var.default_flatcar.boot_order, null)

  cpu   {
    cores         = try(each.value.cpu.vpus, var.default_flatcar.cpu.vpus, 2)
    type          = try(each.value.cpu.type, var.default_flatcar.cpu.type, "host")
  }
  memory                        = try(each.value.memory, var.default_flatcar.memory, 4096)
  start_at_node_boot            = try(each.value.start_on_boot, var.default_flatcar.start_on_boot,true)
  scsihw                        = "virtio-scsi-single"

 
  disks {
      scsi {
          scsi0 {
              disk {
                  discard            = true
                  emulatessd         = true
                  iothread           = true
                  size               = try(each.value.disk_size, var.default_flatcar.disk_size, 32)
                  storage            = try(each.value.disk_datastore, var.default_flatcar.disk_datastore, "Ceph")
              }
          }
      }
      ide {
          ide3 {
              cdrom  {
                  iso = "${proxmox_cloud_init_disk.ci[each.key].id}"
               }
          }
      }
  }

  network {
    id = 0
    model     = try(each.value.network.model, var.default_flatcar.network.model, "virtio")
    bridge    = try(each.value.network.bridge, var.default_flatcar.network.bridge, null)
    tag       = try(each.value.network.vlan, var.default_flatcar.network.vlan, null)
    macaddr   = try(each.value.network.macaddr, null)
    firewall  = try(each.value.network.firewall, each.value.network.firewall, null)
    rate      = try(each.value.network.rate, each.value.network.rate, null)
    link_down = try(each.value.network.link_down, each.value.network.link_down, null)
  }

}



data "ct_config" "ignition_json" {
  for_each = {for k, v in var.flatcar_vms : k => v if !lookup(v, "disabled", false)}
  content = templatefile(each.value.config_file, {
    "vm_name"        = each.key,
    "vm_count"       = local.vm_index[each.key],
    "vm_count_index" = local.vm_index[each.key],
    "share_password" = var.share_password,
    "homelabv2_secret"     = var.homelabv2_secret,
    "traefik_env"      = var.traefik_env,
  })
  strict       = false
  pretty_print = true
}


resource "null_resource" "node_replace_trigger" {
  for_each = {for k, v in var.flatcar_vms : k => v if !lookup(v, "disabled", false)}
  triggers = {
    "ignition" = data.ct_config.ignition_json[each.key].rendered
  }
  lifecycle {
    ignore_changes = [triggers]
  }
}