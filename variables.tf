variable "hcloud_token" {
  sensitive   = true
  description = "The API key used to authenticate with Hetzner Cloud."
}

variable "discord_client_id" {
  sensitive   = true
  description = "Discord OAuth2 client ID."
}

variable "discord_client_secret" {
  sensitive   = true
  description = "Discord OAuth2 client secret."
}

variable "mogboard_pubkey" {
  sensitive   = true
  description = "The public key to use to authenticate to Mogboard servers."
}
