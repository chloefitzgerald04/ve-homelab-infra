default_vm = {
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
         #        "datastore_id"                                  = "Ceph"
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
         "clone"                                                = "flatcar-template"
         "pxe"                                                  = true
         "cdrom" = {
             "iso"                                              = "NAS:iso/archlinux-2024.06.01-x86_64.iso" 
             "interface"                                        = "ide0"
         }
         "agent"                                                = false
         "network_devices" = {
            "0" = {
                "bridge" = "vmbr2"
                "model" = "virtio"
                "vlan_id" = 0
            }
         }

        
}

iso_vms= {
     "VE-PBS-01" = {
         "name" = "ve-pbs-01"
         "node" = "pve3"
         "agent" = true
         "boot_order"                                           = ["scsi0", "ide2", "net0"]
         "cpu" = {
            "vcpus" = 2
         }
         "memory" = {
            "dedicated" = 4096
         }
         "bios" = "ovmf"
         "efi-disk" = { 
            "datastore_id" = "Ceph"
         }
         "tpm" = {
            "enabled" = true
         }
         "cdrom" = {
             "iso" = "ve-nas-01:iso/proxmox-backup-server_4.2-1unattend.iso" 
             "interface" = "ide0"
         }
         "network_devices" = {
            "0" = {
               "model" = "virtio"
               "mac_address" = "bc:24:11:d3:37:56"
            }

         }
         "scsi" = {
             "0" = {
                 "size"                                          = 32
                 "datastore_id"                                  = "Ceph"
                 "discard"                                       = "on"
             }
         }
     }
     "VM1" = {
         "disabled" = true
         "name" = "01"
         "node" = "pve3"
         "cpu" = {
            "vcpus" = 2
         }
         "memory" = {
            "dedicated" = 4096
         }
         "bios" = "seabios"
         "tpm" = {
            "enabled" = false
         }
         #"cdrom" = {
         #    "iso" = "NAS:iso/archlinux-2024.06.01-x86_64.iso" 
         #}
         # "sata" = {
         #    "0" = {
         #        "size" = 32
         #        "datastore_id" = "local-lvm"
         #    }
         # }
         
         "network_devices" = {
            "0" = {
               "model" = "e1000e"
            }

         }
         
     }
     "flatcar-template2" = {
         "name" = "flatcar-template2"
         "node" = "pve3"
         "disabled" = true
         "cpu" = {
            "vcpus" = 2
         }
         "memory" = {
            "dedicated" = 4096
         }
         "clone" = "flatcar-template"
         "bios" = "seabios"
         "network_devices" = {
            "0" = {
               "model" = "e1000e"
            }
         }
         
     }
}
