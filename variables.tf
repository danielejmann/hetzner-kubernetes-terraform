variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
}

variable "num_masters" {
  description = "Number of master nodes"
  type        = number
  default     = 3
}

variable "num_workers" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "network_ip_range" {
  description = "IP range for the network"
  type        = string
  default     = "10.11.11.0/24"
}

variable "cluster1_ip_range" {
  description = "IP range for the subnet for cluster1"
  type        = string
  default     = "10.11.11.0/29"
}

variable "location" {
  description = "Hetzner location for the server"
  type        = string
  default     = "fsn1"
  /* 
  fsn1 - Falkenstein, Germany
  nbg1 - Nuremberg, Germany
  hel1 - Helsinki, Finland
  ash - Ashburn, USA
  hil - Hillsboro, USA
  */
}

variable "network_location" {
  description = "Location for the network"
  type        = string
  default     = "eu-central"
}

# The network_location variable sets eu-central as default as you can't declare a variable without a value.

# The below overrides the network_location depending on the chosen location since Hetzner doesn't bridge networks between geolocations.

locals {
  location_mapping = {
    "fsn1" = "eu-central",
    "nbg1" = "eu-central",
    "hel1" = "eu-central",
    "ash"  = "us-east",
    "hil"  = "us-west",
  }

  chosen_location = try(local.location_mapping[var.location], "eu-central")
}

variable "image" {
  description = "OS image for the servers"
  type        = string
  default     = "ubuntu-22.04"
}

variable "server_type_master" {
  description = "Server type for master nodes"
  type        = string
  default     = "cx21"  # Adjust default server type as needed
}

variable "server_type_worker" {
  description = "Server type for worker nodes"
  type        = string
  default     = "cx31"  # Adjust default server type as needed
}

variable "ansible_ssh_public_key" {
  description = "SSH public key for the ansible user"
  type        = string
}

variable "ansible_ssh_key_type" {
  description = "Type of SSH key for the ansible user"
  type        = string
}
