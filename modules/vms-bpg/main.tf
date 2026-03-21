terraform {
  required_providers {
    bpg = {
      source = "bpg/proxmox"
      version = "0.98.1"
    }
  }
}


resource "proxmox_virtual_environment_vm" "iso_vms" {
    provider                  = bpg
    # IF "disabled" variable added into vm config at any point then the config is not applied / deleted depending if resource has already been created.
    for_each                  = {for k, v in var.iso_vms : k => v if !contains(keys(v), "disabled")}

    ### PVE Options

    name                      = each.value.name
    description               = try(each.value.description, var.default_vm.description, null)
    node_name                 = try(each.value.node, var.default_vm.node, null)
    
    reboot_after_update       = try(each.value.rebootafterupdate, var.default_vm.rebootafterupdate, null)
    stop_on_destroy           = try(var.default_vm.stopondestroy, null)
    bios                      = try(each.value.bios, var.default_vm.bios, null)
    
    boot_order                = try(each.value.bootorder, var.default_vm.bootorder, null)
    on_boot                   = try(each.value.on_boot, var.default_vm.on_boot, null)

    dynamic "clone" {
        for_each = try(each.value.clone, null) != null && try(each.value.pxe, null) != true? [1] : []
        content {
             vm_id            = var.template_id.id["${each.value.clone}"]
        }
    }
    ### RESOURCES

    machine = try(each.value.machine, var.default_vm.machine, null)

    cpu {
        cores                 = try(each.value.cpu.vcpus, var.default_vm.cpu.vcpus, null)
        sockets               = try(each.value.cpu.sockets, var.default_vm.cpu.sockets, null)
        type                  = try(each.value.cpu.type, var.default_vm.cpu.type, null)
    }

    memory {
        dedicated             = try(each.value.memory.dedicated, var.default_vm.memory.dedicated, null)
        floating              = try(each.value.memory.floating, var.default_vm.memory.floating, null)
    }

    operating_system {
        type                  = try(each.value.os, var.default_vm.os, null)
    }

    ### UEFI Options

    dynamic "tpm_state" {
        for_each = try(each.value.tpm.enabled, var.default_vm.tpm.enabled) == true ? [1] : []
        content {
             version          = try(each.value.tpm.version, var.default_vm.tpm.version)
             datastore_id     = try(each.value.tpm.datastore_id, var.default_vm.tpm.datastore_id)
        }
    }
    # only sets if the bios is set to ovmf as seabios doesn't require this
    dynamic "efi_disk" {
        for_each = each.value.bios == "ovmf" ? [1] : []
        content {
             datastore_id     = try(each.value.efi-disk.datastore_id, var.default_vm.efi-disk.datastore_id, null)
        }
    }


    ### DISKS

    scsi_hardware             = try(each.value.scsi_hardware, var.default_vm.scsi_hardware, null)

    dynamic "cdrom"{
        for_each = lookup(each.value, "cdrom", null) == null ? [] : [each.value.cdrom]
        content {
            file_id           = cdrom.value.iso
            interface         = try(cdrom.value.interface, var.default_vm.cdrom.interface, null)
        }
    }

    dynamic "disk" {
        for_each = try(each.value.import, {})
        iterator = import
        content {
            interface         = "scsi0"
            import_from       = proxmox_virtual_environment_download_file.imported_disk[each.value.name].id
            size = 20
        }
    }
    dynamic "disk" {
        for_each = try(each.value.scsi, var.default_vm.scsi, {})
        iterator = data_disk
        content {
            datastore_id      = try( data_disk.value["datastore_id"], var.default_vm.scsi[0].datastore_id, null)
            size              = try( data_disk.value["size"], var.default_vm.scsi[0].size, null)
            file_format       = try( data_disk.value["file_format"], var.default_vm.scsi[0].file_format, null)
            discard           = try( data_disk.value["discard"], var.default_vm.scsi[0].discard, null)
            interface         = "scsi${data_disk.key}"
        }
    }
    dynamic "disk" {
        for_each = try(each.value.virtio, var.default_vm.virtio, {})
        iterator = data_disk
        content {
            datastore_id      = try( data_disk.value["datastore_id"], var.default_vm.virtio[0].datastore_id, null)
            size              = try( data_disk.value["size"], var.default_vm.virtio[0].size, null)
            file_format       = try( data_disk.value["file_format"], var.default_vm.virtio[0].file_format, null)
            discard           = try( data_disk.value["discard"], var.default_vm.virtio[0].discard, null)
            interface         = "virtio${data_disk.key}"
        }
    }
    dynamic "disk" {
        for_each = try(each.value.sata, var.default_vm.sata, {})
        iterator = data_disk
        content {
            datastore_id      = try( data_disk.value["datastore_id"], var.default_vm.sata[0].datastore_id, null)
            size              = try( data_disk.value["size"], var.default_vm.sata[0].size, null)
            file_format       = try( data_disk.value["file_format"], var.default_vm.sata[0].file_format, null)
            discard           = try( data_disk.value["discard"], var.default_vm.sata[0].discard, null)
            interface         = "sata${data_disk.key}"
        }
    }
    dynamic "disk" {
        for_each = try(each.value.ide, var.default_vm.ide, {})
        iterator = data_disk
        content {
            datastore_id      = try( data_disk.value["datastore_id"], var.default_vm.ide[0].datastore_id, null)
            size              = try( data_disk.value["size"], var.default_vm.ide[0].size, null)
            file_format       = try( data_disk.value["file_format"], var.default_vm.ide[0].file_format, null)
            discard           = try( data_disk.value["discard"], var.default_vm.ide[0].discard, null)
            interface         = "ide${data_disk.key + 1}"
        }
    }

    ### NETWORK Adapters

    dynamic "network_device"{
        for_each = try(each.value.network_devices, var.default_vm.network_devices, {})
        iterator = nic
        content {
             bridge          = try(nic.value["bridge"], var.default_vm.network_devices[0].bridge, null)
             vlan_id         = try(nic.value["vlan_id"], var.default_vm.network_devices[0].vlan_id, null)
             model           = try(nic.value["model"], var.default_vm.network_devices[0].model, null)
             mac_address     = try(nic.value["mac_address"], var.default_vm.network_devices[0].mac_address, null)
             mtu             = try(nic.value["mtu"], var.default_vm.network_devices[0].mtu, null)
        }
    }
}
