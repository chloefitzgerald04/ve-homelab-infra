terraform {
  required_providers {
    bpg = {
      source = "bpg/proxmox"
      version = "0.104.0"
    }
  }
}

## BPG doesnt have a way to add as a ha resource during VM creation
# so we need to do it after the fact. 
resource "proxmox_haresource" "iso_vms" {
    provider     = bpg
    for_each     = var.iso_vms
    resource_id  = "vm:${each.value.id}"
    state        = each.value.started == true ? "started" : "stopped"
    comment      = "Managed by Terraform: ./modules/high-availability"
}


## These resources create rules so that VMs prefer the node they are assigned to
## they can still be moved by the cluster if needed but this helps balance things

resource "proxmox_harule" "prefer_pve1" {
    count       = length([for vm in var.flatcar_vms : vm if vm.target_node == "pve1"]) > 0 ? 1 : 0
    provider    = bpg
    depends_on  = [proxmox_haresource.iso_vms]
    rule        = "prefer_pve1"
    type        = "node-affinity"
    comment     = "Prefer pve1 for these VMs"
    resources = concat(
        [for vm in var.flatcar_vms : "vm:${vm.vmid}" if vm.target_node == "pve1"],
        [for vm in var.iso_vms : "vm:${vm.id}" if vm.node_name == "pve1"]
    )

    nodes = {
        pve1    = 2 
        pve2    = 1
        pve3    = 1
    }
    strict      = false
}

resource "proxmox_harule" "prefer_pve2" {
    count       = length([for vm in var.flatcar_vms : vm if vm.target_node == "pve2"]) > 0 ? 1 : 0
    provider    = bpg
    depends_on  = [proxmox_haresource.iso_vms]
    rule        = "prefer_pve2"
    type        = "node-affinity"
    comment     = "Prefer pve2 for these VMs"
    resources = concat(
        [for vm in var.flatcar_vms : "vm:${vm.vmid}" if vm.target_node == "pve2"],
        [for vm in var.iso_vms : "vm:${vm.id}" if vm.node_name == "pve2"]
    )

    nodes = {
        pve1    = 1
        pve2    = 2
        pve3    = 1
    }
    strict      = false
}

resource "proxmox_harule" "prefer_pve3" {
    count       = length([for vm in var.flatcar_vms : vm if vm.target_node == "pve3"]) > 0 ? 1 : 0
    provider    = bpg
    depends_on  = [proxmox_haresource.iso_vms]
    rule        = "prefer_pve3"
    type        = "node-affinity"
    comment     = "Prefer pve3 for these VMs"
    resources = concat(
        [for vm in var.flatcar_vms : "vm:${vm.vmid}" if vm.target_node == "pve3"],
        [for vm in var.iso_vms : "vm:${vm.id}" if vm.node_name == "pve3"]
    )
    nodes = {
        pve1    = 1
        pve2    = 1
        pve3    = 2
    }
    strict      = false
}


