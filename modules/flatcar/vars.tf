variable "share_password" {
  description = "password for network share used in ignition config for media"
  type        = string
  sensitive   = true
  default     = ""
}

variable "homelabv2_secret" {
  sensitive   = true
  default     = ""
}
variable "template_id" {
  description = ""
}
variable "default_flatcar" {
    default = {}
}
variable "flatcar_vms" {
    default = {}
}


variable "traefik_env" {
  sensitive  = true
  default = ""
}