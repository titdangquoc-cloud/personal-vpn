resource "digitalocean_ssh_key" "admin" {
  name       = "vpn-admin"
  public_key = file(pathexpand("~/.ssh/vpn_admin.pub"))
}

resource "digitalocean_droplet" "vpn" {
  name       = "vpn-syd"
  region     = var.region
  size       = "s-1vcpu-1gb"
  image      = "ubuntu-24-04-x64"
  ssh_keys   = [digitalocean_ssh_key.admin.fingerprint]
  monitoring = true
}

resource "digitalocean_firewall" "vpn" {
  name        = "vpn-firewall"
  droplet_ids = [digitalocean_droplet.vpn.id]

  # SSH only from your IP
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.admin_ip]
  }

  # WireGuard from anywhere
  inbound_rule {
    protocol         = "udp"
    port_range       = "51820"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow all outbound so the server can reach the internet
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}