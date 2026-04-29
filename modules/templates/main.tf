terraform {
  required_providers {
    bpg = {
      source = "bpg/proxmox"
      version = "0.104.0"
    }
  }
}


resource "proxmox_virtual_environment_vm" "custom_templates" {
    provider                  = bpg
    # IF "disabled" variable added into vm config at any point then the config is not applied / deleted depending if resource has already been created.
    for_each                  = {for k, v in var.custom_templates : k => v if !contains(keys(v), "disabled")}

    ### PVE Options

    name                      = each.value.name
    description               = try(each.value.description, var.default_templates.description, null)
    node_name                 = try(each.value.node, var.default_templates.node, null)
    
    reboot_after_update       = try(each.value.rebootafterupdate, var.default_templates.rebootafterupdate, null)
    stop_on_destroy           = try(var.default_templates.stopondestroy, null)
    bios                      = try(each.value.bios, var.default_templates.bios, null)
    
    boot_order                = try(each.value.bootorder, var.default_templates.bootorder, null)
    on_boot                   = try(each.value.on_boot, var.default_templates.on_boot, null)
    template                  = true
    dynamic "clone" {
        for_each = try(each.value.clone, var.default_templates.clone) != false && try(each.value.pxe) != true? [1] : []
        content {
             vm_id            = try(each.value.clone, var.default_templates.clone, null)
        }
    }
    ### RESOURCES

    machine = try(each.value.machine, var.default_templates.machine, null)

    cpu {
        cores                 = try(each.value.cpu.vcpus, var.default_templates.cpu.vcpus, null)
        sockets               = try(each.value.cpu.sockets, var.default_templates.cpu.sockets, null)
        type                  = try(each.value.cpu.type, var.default_templates.cpu.type, null)
    }

    memory {
        dedicated             = try(each.value.memory.dedicated, var.default_templates.memory.dedicated, null)
        floating              = try(each.value.memory.floating, var.default_templates.memory.floating, null)
    }

    operating_system {
        type                  = try(each.value.os, var.default_templates.os, null)
    }

    ### UEFI Options

    dynamic "tpm_state" {
        for_each = try(each.value.tpm.enabled, var.default_templates.tpm.enabled) == true ? [1] : []
        content {
             version          = try(each.value.tpm.version, var.default_templates.tpm.version)
             datastore_id     = try(each.value.tpm.datastore_id, var.default_templates.tpm.datastore_id)
        }
    }
    # only sets if the bios is set to ovmf as seabios doesn't require this
    dynamic "efi_disk" {
        for_each = each.value.bios == "ovmf" ? [1] : []
        content {
             datastore_id     = try(each.value.efi-disk.datastore_id, var.default_templates.efi-disk.datastore_id, null)
        }
    }


    ### DISKS

    scsi_hardware             = try(each.value.scsi_hardware, var.default_templates.scsi_hardware, null)

    dynamic "cdrom"{
        for_each = lookup(each.value, "cdrom", null) == null ? [] : [each.value.cdrom]
        content {
            file_id           = cdrom.value.iso
            interface         = try(cdrom.value.interface, var.default_templates.cdrom.interface, null)
        }
    }

    dynamic "disk" {
        for_each = try(each.value.import, {})
        iterator = import
        content {
            interface         =  import.value.interface
            #import_from       = proxmox_virtual_environment_download_file.imported_disk[each.value.name].id
            import_from = var.imported_disk.id["${import.value.name}"]
            size = import.value.size
            datastore_id = import.value.datastore
        }
    }
    dynamic "disk" {
        for_each = try(each.value.scsi, var.default_templates.scsi, {})
        iterator = data_disk
        content {
            datastore_id      = try( data_disk.value["datastore_id"], var.default_templates.scsi[0].datastore_id, null)
            size              = try( data_disk.value["size"], var.default_templates.scsi[0].size, null)
            file_format       = try( data_disk.value["file_format"], var.default_templates.scsi[0].file_format, null)
            discard           = try( data_disk.value["discard"], var.default_templates.scsi[0].discard, null)
            interface         = "scsi${data_disk.key}"
        }
    }
    dynamic "disk" {
        for_each = try(each.value.virtio, var.default_templates.virtio, {})
        iterator = data_disk
        content {
            datastore_id      = try( data_disk.value["datastore_id"], var.default_templates.virtio[0].datastore_id, null)
            size              = try( data_disk.value["size"], var.default_templates.virtio[0].size, null)
            file_format       = try( data_disk.value["file_format"], var.default_templates.virtio[0].file_format, null)
            discard           = try( data_disk.value["discard"], var.default_templates.virtio[0].discard, null)
            interface         = "virtio${data_disk.key}"
        }
    }
    dynamic "disk" {
        for_each = try(each.value.sata, var.default_templates.sata, {})
        iterator = data_disk
        content {
            datastore_id      = try( data_disk.value["datastore_id"], var.default_templates.sata[0].datastore_id, null)
            size              = try( data_disk.value["size"], var.default_templates.sata[0].size, null)
            file_format       = try( data_disk.value["file_format"], var.default_templates.sata[0].file_format, null)
            discard           = try( data_disk.value["discard"], var.default_templates.sata[0].discard, null)
            interface         = "sata${data_disk.key}"
        }
    }
    dynamic "disk" {
        for_each = try(each.value.ide, var.default_templates.ide, {})
        iterator = data_disk
        content {
            datastore_id      = try( data_disk.value["datastore_id"], var.default_templates.ide[0].datastore_id, null)
            size              = try( data_disk.value["size"], var.default_templates.ide[0].size, null)
            file_format       = try( data_disk.value["file_format"], var.default_templates.ide[0].file_format, null)
            discard           = try( data_disk.value["discard"], var.default_templates.ide[0].discard, null)
            interface         = "ide${data_disk.key + 1}"
        }
    }

    ### NETWORK Adapters

    dynamic "network_device"{
        for_each = try(each.value.network_devices, var.default_templates.network_devices, {})
        iterator = nic
        content {
             bridge          = try(nic.value["bridge"], var.default_templates.network_devices[0].bridge, null)
             vlan_id         = try(nic.value["vlan_id"], var.default_templates.network_devices[0].vlan_id, null)
             model           = try(nic.value["model"], var.default_templates.network_devices[0].model, null)
             mac_address     = try(nic.value["mac_address"], var.default_templates.network_devices[0].mac_address, null)
             mtu             = try(nic.value["mtu"], var.default_templates.network_devices[0].mtu, null)
            # bridge          = try(nic.value["bridge"], var.default_templates.network_devices.0.bridge, null)
            # vlan_id         = try(nic.value["vlan_id"], var.default_templates.network_devices.0.vlan_id, null)
            # model           = try(nic.value["model"], var.default_templates.network_devices.0.model, null)
            # mac_address     = try(nic.value["mac_address"], var.default_templates.network_devices.0.mac_address, null)
            # mtu             = try(nic.value["mtu"], var.default_templates.network_devices.0.mtu, null)
        }
    }
}
