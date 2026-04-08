provider "telmate" {
  pm_api_url = var.api_url
  pm_api_token_id = var.token_id
  pm_api_token_secret = var.token_secret
  pm_tls_insecure = true

}


provider "bpg" {
  endpoint = "https://10.0.0.101:8006"
  api_token = "${var.token_id}=${var.token_secret}"
  insecure = true 
  }

#provider "bpg" {
#  endpoint = "https://10.0.10.200:8006"
#  api_token = "${var.token_id}=${var.token_secret}"
#  insecure = true
#}