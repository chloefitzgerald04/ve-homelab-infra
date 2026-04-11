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
         "stop_on_destroy"                                      = true
         "start_on_boot"                                        = true
         "network" = {
                "bridge" = "vmbr2"
                "model" = "virtio"
                "vlan_id" = 0
         }
         "disk_size"                                            = 32
         "disk_datastore"                                       = "Ceph"    
}


flatcar_vms = {
     "flatcar-01" = {
         "disabled" = true
         "config_file" = "butane_configs/1-config.bu.tftpl"
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
     "flatcar-02" = {
         "disabled" = true
         "config_file" = "butane_configs/2-config.bu.tftpl"
         "start_on_boot" = true
         "node" = "pve3"
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
     "ve-traefik" = {
         "disabled" = false
         "config_file" = "butane_configs/3-config.bu.tftpl"
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
}