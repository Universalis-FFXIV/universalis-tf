# Provision a network
resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}

# Provision a subnet
resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# Provision a firewall
resource "hcloud_firewall" "swarm_firewall" {
  name = "swarm-firewall"

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
  // TODO: Use bastion instead for local
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = [var.local_ip]
  }

  // Docker Swarm
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "any"
    source_ips = ["10.0.0.0/16"]
  }

  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "any"
    source_ips = ["10.0.0.0/16"]
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

# TODO: Add a bastion

resource "hcloud_ssh_key" "swarm_ssh" {
  name       = "Swarm"
  public_key = var.mogboard_pubkey
}

# Provision the manager nodes
resource "hcloud_server" "swarm_manager_1" {
  name               = "swarm-manager-1"
  server_type        = "cx11"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.1"
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

resource "hcloud_server" "swarm_manager_2" {
  name               = "swarm-manager-2"
  server_type        = "cx11"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true

  network {
    network_id = hcloud_network.network.id
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

resource "hcloud_server" "swarm_manager_3" {
  name               = "swarm-manager-3"
  server_type        = "cx11"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true

  network {
    network_id = hcloud_network.network.id
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

output "swarm_manager_1_ip" {
  value = hcloud_server.swarm_manager_1.ipv4_address
}

output "swarm_manager_2_ip" {
  value = hcloud_server.swarm_manager_2.ipv4_address
}

output "swarm_manager_3_ip" {
  value = hcloud_server.swarm_manager_3.ipv4_address
}

# Provision worker nodes

# MariaDB is assigned to this node
resource "hcloud_server" "swarm_worker_1" {
  name               = "swarm-worker-1"
  server_type        = "cx21"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true

  network {
    network_id = hcloud_network.network.id
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

# Postgres is assigned to this node
resource "hcloud_server" "swarm_worker_2" {
  name               = "swarm-worker-2"
  server_type        = "cx31"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true

  network {
    network_id = hcloud_network.network.id
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

resource "hcloud_server" "swarm_worker_3" {
  name               = "swarm-worker-3"
  server_type        = "cx11"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true

  network {
    network_id = hcloud_network.network.id
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

output "swarm_worker_1_ip" {
  value = hcloud_server.swarm_worker_1.ipv4_address
}

output "swarm_worker_2_ip" {
  value = hcloud_server.swarm_worker_2.ipv4_address
}

output "swarm_worker_3_ip" {
  value = hcloud_server.swarm_worker_3.ipv4_address
}

# Volumes for the website and API databases
resource "hcloud_volume" "website_db" {
  name              = "website-db"
  location          = "hel1"
  size              = 10
  format            = "ext4"
  delete_protection = true
}

resource "hcloud_volume" "api_db" {
  name              = "api-db"
  location          = "hel1"
  size              = 20
  format            = "ext4"
  delete_protection = true
}

resource "hcloud_volume_attachment" "website_db_ref" {
  volume_id = hcloud_volume.website_db.id
  server_id = hcloud_server.swarm_worker_1.id
  automount = true
}

resource "hcloud_volume_attachment" "api_db_ref" {
  volume_id = hcloud_volume.api_db.id
  server_id = hcloud_server.swarm_worker_2.id
  automount = true
}

# Add servers to the firewall
resource "hcloud_firewall_attachment" "swarm_firewall_ref" {
  firewall_id = hcloud_firewall.swarm_firewall.id
  server_ids = [
    hcloud_server.swarm_manager_1.id,
    hcloud_server.swarm_manager_2.id,
    hcloud_server.swarm_manager_3.id,
    hcloud_server.swarm_worker_1.id,
    hcloud_server.swarm_worker_2.id,
    hcloud_server.swarm_worker_3.id
  ]
}
