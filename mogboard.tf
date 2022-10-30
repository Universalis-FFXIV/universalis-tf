# This configuration file describes all of the resources provisioned for the Universalis website (Mogboard).

resource "hcloud_ssh_key" "mogboard_ssh" {
  name       = "Mogboard"
  public_key = var.mogboard_pubkey
  labels = {
    "service" : "mogboard"
  }
}

resource "hcloud_firewall" "mogboard_firewall" {
  name = "mogboard-firewall"
  labels = {
    "service" : "mogboard"
  }

  // ICMP ping
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  // SSH
  // TODO: Lock this down
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  // HTTP
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  // HTTPS
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_primary_ip" "mogboard_public_ip" {
  name          = "mogboard-public-ip"
  datacenter    = "hel1-dc2"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false
  labels = {
    "service" : "mogboard"
  }
}

output "mogboard_public_ip" {
  description = "Mogboard public IP address"
  value       = hcloud_primary_ip.mogboard_public_ip.ip_address
}

resource "hcloud_volume" "mogboard_db_volume" {
  name     = "mogboard-db"
  size     = 50
  format   = "ext4"
  location = "hel1"
}

resource "random_password" "mogboard_nextauth_secret" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "mogboard_db_secret" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

output "mogboard_db_secret" {
  sensitive   = true
  description = "Mogboard DB secret"
  value       = random_password.mogboard_db_secret.result
}

resource "hcloud_server" "mogboard_node_1" {
  name        = "mogboard-node-1"
  image       = "docker-ce"
  server_type = "cx11"
  datacenter  = "hel1-dc2"
  keep_disk   = true
  ssh_keys    = [hcloud_ssh_key.mogboard_ssh.name]
  labels = {
    "service" : "mogboard"
  }

  user_data = templatefile("./config/mogboard_node_1/cloud-init.yml", {
    docker_compose = base64encode(templatefile("./config/mogboard_node_1/docker-compose.yml", {
      discord_client_id     = var.discord_client_id
      discord_client_secret = var.discord_client_secret
      nextauth_secret       = random_password.mogboard_nextauth_secret.result
      db_secret             = random_password.mogboard_db_secret.result
    }))
    sqlinit   = base64encode(file("./config/mogboard_node_1/sqlinit.tar"))
    volume_id = hcloud_volume.mogboard_db_volume.id
  })

  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.mogboard_public_ip.id
    ipv6_enabled = false
  }
}

resource "hcloud_firewall_attachment" "mogboard_firewall_attachment" {
  firewall_id = hcloud_firewall.mogboard_firewall.id
  server_ids  = [hcloud_server.mogboard_node_1.id]
}

resource "hcloud_volume_attachment" "mogboard_db_volume_attachment" {
  volume_id = hcloud_volume.mogboard_db_volume.id
  server_id = hcloud_server.mogboard_node_1.id
}
