output "out_import_id" {
    value = {
        id = "${zipmap(values(proxmox_download_file.imported_disk).*.file_name, values(proxmox_download_file.imported_disk).*.id, )}"
    }
}