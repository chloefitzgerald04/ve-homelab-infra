output "out_vm_ip" {
  value = {
    for name, vm in proxmox_virtual_environment_vm.iso_vms : name => {
      id = vm.id
      ip = [for ip in flatten(vm.ipv4_addresses) : ip if ip != "127.0.0.1"][0]
    }
  }
}

output "iso_vms" {
    value = proxmox_virtual_environment_vm.iso_vms
}