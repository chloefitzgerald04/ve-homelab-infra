default_flatcar = {
         "node"                                                 = "pve3"
         "description"                                          = "Default config for vm"
         "stopondestroy"                                        = true
         "startup" = {
             "order"                                            = "3"
             "up_delay"                                         = "60"
             "down_delay"                                       = "60"
         }
        "boot_order"                                            =  "order=scsi0;ide3;net0"
        "cpu" = {
            "vcpus"                                             = 2 
            "sockets"                                           = 1
            "type"                                              = "host"
         }

         "memory"                                               = 4096
         "reboot_after_update"                                  = "true"
         "automatic_reboot_severity"                            = "error"
         "machine"                                              = "pc"
         "stop_on_destroy"                                      = true
         "start_on_boot"                                        = true
         "startup_delay"                                        = 180    
         "network" = {
                "bridge" = "vmbr2"
                "model" = "virtio"
                "vlan_id" = 0
         }
         "disk_size"                                            = 32
         "disk_datastore"                                       = "Ceph"   
         
         "pci_passthrough"                                      = false 
}


flatcar_vms = {
     "fc-plex" = {
         "disabled" = false
         "config_file" = "configs/butane/plex-config.bu.tftpl"
         "start_on_boot" = true
         "node" = "pve3"
         "vcpus" = 4
         "memory" = 8192
         "disk_size" = 32
         "machine" = "q35"
         "pci_passthrough" = true
         "disk_datastore" = "Ceph"
         "network" = {
            "model" = "virtio"
            "bridge" = "vmbr2"
            "vlan" = 0
         }
         
     }
     "fc-arr-stack" = {
         "disabled" = false
         "config_file" = "configs/butane/arr-config.bu.tftpl"
         "start_on_boot" = true
         "node" = "pve1"
         "vcpus" = 2
         "memory" = 4096
         "disk_size" = 32
         "disk_datastore" = "Ceph"
         "network" = {
            "model" = "virtio"
            "bridge" = "vmbr2"
            "vlan" = 0
         }
         
     }
     "fc-traefik" = {
         "disabled" = false
         "config_file" = "configs/butane/traefik-config.bu.tftpl"
         "start_on_boot" = true
         "node" = "pve2"
         "vcpus" = 2
         "memory" = 2048
         "disk_size" = 32
         "disk_datastore" = "Ceph"
         "network" = {
            "model" = "virtio"
            "bridge" = "vmbr2"
            "vlan" = 0
         }
         
     }
     "fc-monitoring" = {
         "disabled" = false
         "config_file" = "configs/butane/zabbix-config.bu.tftpl"
         "start_on_boot" = true
         "node" = "pve2"
         "vcpus" = 2
         "memory" = 4096
         "disk_size" = 60
         "disk_datastore" = "Ceph"
         "network" = {
            "model" = "virtio"
            "bridge" = "vmbr2"
            "vlan" = 0
         }
         
     }
}