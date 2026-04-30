default_templates = {
         "node"                                                 = "pve3"
         "os"                                                   = "l26"
         "machine"                                              = "pc" # pc (i440FX) or q35
         "description"                                          = "Default config for vm"
         "agent"                                                = false
         "on_boot"                                              = true
         "stopondestroy"                                        = true
         "bootorder"                                            = ["scsi0", "ide0", "net0"]
         "template"                                             = false
         "startup" = {
             "order"                                            = "3"
             "up_delay"                                         = "60"
             "down_delay"                                       = "60"
         }
         "cpu" = {
            "vcpus"                                             = 2 
            "sockets"                                           = 1
            "type"                                              = "x86-64-v2-AES"
         }
         "memory" = {
            "dedicated"                                         = 4096
            "floating"                                          = 0
         }
         "scsi_hardware"                                        = "virtio-scsi-pci"
         # "scsi" = {
         #    "0" = {
         #        "size"                                          = 32
         #        "datastore_id"                                  = "local-lvm"
         #        "discard"                                       = "on"
         #    }
         # }
         "bios"                                                 = "seabios" # or ovmf
         "efi-disk" = { # Required if bios set to ovmf
            "datastore_id"                                      = "Ceph"
         }
         "rebootafterupdate"                                    = "true"
         "tpm" = {
            "enabled"                                           = false
            "version"                                           = "v2.0"
            "datastore_id"                                      = "Ceph"
         }
         "stop_on_destroy"                                      = true
         "startup"                                              = false
         "boot_order"                                           = ["scsi0", "ide2", "net0"]
         "clone"                                                = "100"
         "pxe"                                                  = true
         "cdrom" = {
             "iso"                                              = "NAS:iso/archlinux-2024.06.01-x86_64.iso" 
             "interface"                                        = "ide0"
         }
         "network_devices" = {
            "0" = {
                "bridge" = "vmbr0"
                "model" = "virtio"
                "vlan_id" = 0
            }
         }
}


custom_templates = {
     "flatcar-template" = {
         "name" = "flatcar-template"
         "node" = "pve3"
         "cpu" = {
            "vcpus" = 2
         }
         "memory" = {
            "dedicated" = 4096
         }
         # "import" = {
         #       "import_from" = "https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_proxmoxve_image.img"
         #       "datastore_id" = "Ceph"
         # }
         "import" = {
            "0" = {
               "name" = "flatcar-proxmox.qcow2"
               "size" = "20"
               "datastore" = "Ceph"
               "interface" = "scsi0"
            }
         }
         "pxe" = true
         "bios" = "seabios"
         "network_devices" = {
            "0" = {
               "model" = "e1000e"
            }
         }
         
     }
}