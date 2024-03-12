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
    source_ips = ["10.0.0.0/16", "95.216.241.171/32"]
  }

  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "any"
    source_ips = ["10.0.0.0/16", "95.216.241.171/32"]
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

  // HTTP/3
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "udp"
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
  server_type        = "cpx31"
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

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

resource "hcloud_server" "swarm_manager_2" {
  name               = "swarm-manager-2"
  server_type        = "cpx31"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.2"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

resource "hcloud_server" "swarm_manager_3" {
  name               = "swarm-manager-3"
  server_type        = "cpx31"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.3"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
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
  server_type        = "cpx31"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.4"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

resource "hcloud_server" "swarm_worker_2" {
  name               = "swarm-worker-2"
  server_type        = "cpx31"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.5"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

resource "hcloud_server" "swarm_worker_3" {
  name               = "swarm-worker-3"
  server_type        = "cpx31"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.6"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

resource "hcloud_server" "swarm_worker_5" {
  name               = "swarm-worker-5"
  server_type        = "cpx31"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.10"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
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

output "swarm_worker_5_ip" {
  value = hcloud_server.swarm_worker_5.ipv4_address
}

resource "hcloud_server" "scylla_1" {
  name               = "scylla-1"
  server_type        = "ccx23"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true
  backups            = true

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.7"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

resource "hcloud_server" "scylla_2" {
  name               = "scylla-2"
  server_type        = "ccx23"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true
  backups            = true

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.8"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

resource "hcloud_server" "scylla_3" {
  name               = "scylla-3"
  server_type        = "ccx23"
  image              = "docker-ce"
  location           = "hel1"
  keep_disk          = true
  ssh_keys           = [hcloud_ssh_key.swarm_ssh.id]
  delete_protection  = true
  rebuild_protection = true
  backups            = true

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.9"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

output "scylla_1_ip" {
  value = hcloud_server.scylla_1.ipv4_address
}

output "scylla_2_ip" {
  value = hcloud_server.scylla_2.ipv4_address
}

output "scylla_3_ip" {
  value = hcloud_server.scylla_3.ipv4_address
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
  size              = 120
  format            = "ext4"
  delete_protection = true
}

resource "hcloud_volume" "api_db_1" {
  name              = "api-db-1"
  location          = "hel1"
  size              = 120
  format            = "xfs"
  delete_protection = true
}

resource "hcloud_volume" "api_db_2" {
  name              = "api-db-2"
  location          = "hel1"
  size              = 120
  format            = "xfs"
  delete_protection = true
}

resource "hcloud_volume" "api_db_3" {
  name              = "api-db-3"
  location          = "hel1"
  size              = 120
  format            = "xfs"
  delete_protection = true
}

resource "hcloud_volume" "metrics_db" {
  name              = "metrics-db"
  location          = "hel1"
  size              = 40
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

resource "hcloud_volume_attachment" "api_db_1_ref" {
  volume_id = hcloud_volume.api_db_1.id
  server_id = hcloud_server.scylla_1.id
  automount = true
}

resource "hcloud_volume_attachment" "api_db_2_ref" {
  volume_id = hcloud_volume.api_db_2.id
  server_id = hcloud_server.scylla_2.id
  automount = true
}

resource "hcloud_volume_attachment" "api_db_3_ref" {
  volume_id = hcloud_volume.api_db_3.id
  server_id = hcloud_server.scylla_3.id
  automount = true
}

resource "hcloud_volume_attachment" "metrics_db_ref" {
  volume_id = hcloud_volume.metrics_db.id
  server_id = hcloud_server.swarm_manager_2.id
  automount = true
}

# Set up load balancer
resource "hcloud_load_balancer" "lb_swarm" {
  name               = "load-balancer"
  load_balancer_type = "lb21"
  location           = "hel1"
  delete_protection  = true
  algorithm {
    type = "least_connections"
  }
}

output "swarm_load_balancer_ip" {
  value = hcloud_load_balancer.lb_swarm.ipv4
}

resource "hcloud_load_balancer_network" "lb_swarm_network" {
  load_balancer_id = hcloud_load_balancer.lb_swarm.id
  network_id       = hcloud_network.network.id
  ip               = "10.0.1.240"
}

resource "hcloud_load_balancer_service" "lb_service_swarm_http" {
  load_balancer_id = hcloud_load_balancer.lb_swarm.id
  protocol         = "tcp"
  listen_port      = 80
  destination_port = 80
}

resource "hcloud_load_balancer_service" "lb_service_swarm_https" {
  load_balancer_id = hcloud_load_balancer.lb_swarm.id
  protocol         = "tcp"
  listen_port      = 443
  destination_port = 443
}

resource "hcloud_load_balancer_target" "lb_target_swarm_manager_1" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb_swarm.id
  server_id        = hcloud_server.swarm_manager_1.id
}

resource "hcloud_load_balancer_target" "lb_target_swarm_manager_2" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb_swarm.id
  server_id        = hcloud_server.swarm_manager_2.id
}

resource "hcloud_load_balancer_target" "lb_target_swarm_manager_3" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb_swarm.id
  server_id        = hcloud_server.swarm_manager_3.id
}

resource "hcloud_load_balancer_target" "lb_target_swarm_worker_1" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb_swarm.id
  server_id        = hcloud_server.swarm_worker_1.id
}

resource "hcloud_load_balancer_target" "lb_target_swarm_worker_2" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb_swarm.id
  server_id        = hcloud_server.swarm_worker_2.id
}

resource "hcloud_load_balancer_target" "lb_target_swarm_worker_3" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb_swarm.id
  server_id        = hcloud_server.swarm_worker_3.id
}

resource "hcloud_load_balancer_target" "lb_target_swarm_worker_4" {
  type             = "ip"
  load_balancer_id = hcloud_load_balancer.lb_swarm.id
  ip               = "95.216.241.171"
}

resource "hcloud_load_balancer_target" "lb_target_swarm_worker_5" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb_swarm.id
  server_id        = hcloud_server.swarm_worker_5.id
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
    hcloud_server.swarm_worker_3.id,
    hcloud_server.swarm_worker_5.id,
    hcloud_server.scylla_1.id,
    hcloud_server.scylla_2.id,
    hcloud_server.scylla_3.id
  ]
}
