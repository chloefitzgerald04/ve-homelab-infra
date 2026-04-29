default_cifs = {
    "server"              = "0.0.0.0"
    "username"            = ""
    "domain"              = "WORKGROUP"
    "share"               = ""
    "subdirectory"        = ""
    "preallocation"      = "metadata"
    "disable"             = true
    "content_types"       = ["backup", "images", "import", "iso", "rootdir", "snippets", "vztmpl"]
    "nodes"               = ["pve1", "pve2", "pve3"]
    "backups" = {
        "keep_all"           = false
        "keep_last"          = 5
        "keep_hourly"        = 0
        "keep_daily"         = 7
        "keep_weekly"        = 4
        "keep_monthly"       = 12
        "keep_yearly"        = 0
        "max_promox_backups"     = 0
    }
}

custom_cifs = {
  ve-nas-01-pbs = {
    "server"              = "10.0.10.210"
    "username"            = "pve"
    "share"               = "backups"
    "content_types"       = ["backup"]
    "subdirectory"        = "/pbs"

  }
}