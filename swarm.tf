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
    source_ips = [var.local_ip, "10.0.1.0/24"]
  }

  // Docker Swarm
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "2377"
    source_ips = ["10.0.1.0/24"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "7946"
    source_ips = ["10.0.1.0/24"]
  }

  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "7946"
    source_ips = ["10.0.1.0/24"]
  }

  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "4789"
    source_ips = ["10.0.1.0/24"]
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

# Provision the manager node
resource "hcloud_server" "swarm_manager_1" {
  name        = "swarm-manager-1"
  server_type = "cx11"
  image       = "docker-ce"
  location    = "hel1"
  keep_disk   = true
  ssh_keys    = [hcloud_ssh_key.swarm_ssh.id]

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.1"
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

output "swarm_manager_1_ip" {
  value = hcloud_server.swarm_manager_1.ipv4_address
}

# Provision worker nodes
resource "hcloud_server" "swarm_worker_1" {
  name        = "swarm-worker-1"
  server_type = "cx11"
  image       = "docker-ce"
  location    = "hel1"
  keep_disk   = true
  ssh_keys    = [hcloud_ssh_key.swarm_ssh.id]

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.2"
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]
}

resource "hcloud_server" "swarm_worker_2" {
  name        = "swarm-worker-2"
  server_type = "cx11"
  image       = "docker-ce"
  location    = "hel1"
  keep_disk   = true
  ssh_keys    = [hcloud_ssh_key.swarm_ssh.id]

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.3"
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

# Add servers to the firewall
resource "hcloud_firewall_attachment" "swarm_firewall_ref" {
  firewall_id = hcloud_firewall.swarm_firewall.id
  server_ids  = [hcloud_server.swarm_manager_1.id, hcloud_server.swarm_worker_1.id, hcloud_server.swarm_worker_2.id]
}

# Load balancer
resource "hcloud_load_balancer" "lb" {
  name               = "swarm-load-balancer"
  load_balancer_type = "lb11"
  location           = "hel1"
}

resource "hcloud_load_balancer_target" "lb_target_1" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb.id
  server_id        = hcloud_server.swarm_worker_1.id
}

resource "hcloud_load_balancer_target" "lb_target_2" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb.id
  server_id        = hcloud_server.swarm_worker_2.id
}

resource "hcloud_load_balancer_network" "lb_network" {
  load_balancer_id = hcloud_load_balancer.lb.id
  network_id       = hcloud_network.network.id
  ip               = "10.0.1.70"
}

output "load_balancer_ip" {
  value       = hcloud_load_balancer.lb.ipv4
  description = "LoadBalancer IP"
}
