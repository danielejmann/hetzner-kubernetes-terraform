# Creates a network within Hetzner named k8s-network, range defined as a variable.

resource "hcloud_network" "k8s-network" {
  name     = "k8s-network"
  ip_range   = var.network_ip_range
}

# Creates a smaller subnet within the network named cluster1-network, ranged defined as a variable.

resource "hcloud_network_subnet" "cluster1-network" {
  network_id   = hcloud_network.k8s-network.id
  type         = "cloud"
  network_zone = local.chosen_location
  ip_range   = var.cluster1_ip_range
}

# Creates a spread placement to spread the VMs between different nodes and DCs within the location for redundancy. The placement is static as Hetzner only allows 'spread' placements.

resource "hcloud_placement_group" "spread-placement" {
  name = "spread-placement"
  type = "spread"
}

# Create the master nodes, named k8s-master-* which will increment depending on how many nodes are selected. Use cloud-init to create a user named 'ansible' on the server, no password sudo rights and add the public key defined as a variable.

#Create a depends on cluster1-network so the VM isn't created before the subnet is in place.

resource "hcloud_server" "master" {
  count      = var.num_masters
  name       = "k8s-master-${count.index + 1}"
  image       = var.image
  server_type = var.server_type_master
  placement_group_id = hcloud_placement_group.spread-placement.id
  location   = var.location
  network {
    network_id = hcloud_network.k8s-network.id
    ip         = cidrhost(var.cluster1_ip_range, count.index + 2)
  }
  user_data = <<-EOF
   #cloud-config
   users:
      - name: ansible
        groups: sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - "${var.ansible_ssh_key_type} ${var.ansible_ssh_public_key}"
        sudo: ALL=(ALL) NOPASSWD:ALL
  EOF
  depends_on = [
    hcloud_network_subnet.cluster1-network
  ]
}

# Create the workers nodes, named k8s-workers-* which will increment depending on how many nodes are selected. Use cloud-init to create a user named 'ansible' on the server, no password sudo rights and add the public key defined as a variable.

#Create a depends on cluster1-network so the VM isn't created before the subnet is in place.

resource "hcloud_server" "worker" {
  count      = var.num_workers
  name       = "k8s-worker-${count.index + 1}"
  image       = var.image
  server_type = var.server_type_worker
  placement_group_id = hcloud_placement_group.spread-placement.id
  location   = var.location
  network {
    network_id = hcloud_network.k8s-network.id
    ip         = cidrhost(var.cluster1_ip_range, var.num_masters + count.index + 2)
  }
  user_data = <<-EOF
   #cloud-config
   users:
      - name: ansible
        groups: sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - "${var.ansible_ssh_key_type} ${var.ansible_ssh_public_key}"
        sudo: ALL=(ALL) NOPASSWD:ALL
  EOF
  depends_on = [
    hcloud_network_subnet.cluster1-network
  ]
}

# Create a output of the VM IPs and hostnames created after the resources have been created

output "master_server_ips" {
  description = "Hostnames and IP addresses of the master servers"
  value = [
    for instance in hcloud_server.master :
    {
      hostname = instance.name
      ip       = instance.ipv4_address
    }
  ]
}

output "worker_server_ips" {
  description = "Hostnames and IP addresses of the worker servers"
  value = [
    for instance in hcloud_server.worker :
    {
      hostname = instance.name
      ip       = instance.ipv4_address
    }
  ]
}
