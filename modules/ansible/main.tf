terraform {
  required_providers {
    ansible = {
      version = "~> 1.4.0"
      source  = "ansible/ansible"
    }
  }
}



resource "time_sleep" "wait_180_seconds" {
  create_duration = "180s"
}


data "ansible_inventory" "inv" {
  depends_on = [time_sleep.wait_180_seconds]
  group {
    name = "bpg"

    dynamic "host" {
        for_each = {for k, v in var.iso_vms : k => v if !contains(keys(v), "disabled")}
        content {
            name                     = var.bpg_ips[host.key].ip
            ansible_user             = "root"
            #ansible_private_key_file = local_file.private_key.filename
        }
    }
  }
}

resource "local_file" "inventory-json" {
  content  = data.ansible_inventory.inv.json
  filename = "configs/ansible/inventory.json"
}
