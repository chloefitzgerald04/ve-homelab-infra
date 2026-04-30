variable "default_cifs" {  
}
variable "custom_cifs" {
}

variable "cifs_password" {
  sensitive   = true
  default     = ""
}