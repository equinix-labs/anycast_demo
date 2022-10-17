# Andree Toonk
# Feb 23, 2019

terraform {
  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = "1.6.0"
    }
  }
}

provider "equinix" {
  auth_token = var.packet_api_key
}

# Create project
resource "equinix_metal_project" "anycast_test" {
  name = "anycast-test-cobalt"
  bgp_config {
    deployment_type = "local"
    #md5 = "${var.bgp_password}"
    asn = 65000
  }
}

# Create a Global IPv4 IP to be used for Anycast
# the Actual Ip is available as: packet_reserved_ip_block.anycast_ip.address
# We'll pass that along to each compute node, so they can assign it to all nodes and announce it in BGP

resource "equinix_metal_reserved_ip_block" "anycast_ip" {
  project_id = equinix_metal_project.anycast_test.id
  type       = "global_ipv4"
  quantity   = 1
}

module "compute_sv" {
  source           = "./modules/compute"
  project_id       = equinix_metal_project.anycast_test.id
  anycast_ip       = equinix_metal_reserved_ip_block.anycast_ip.address
  operating_system = "ubuntu_22_04"
  instance_type    = "c3.small.x86"
  metro            = "sv"
  compute_count    = "2"
  database_url     = var.database_url
}

module "compute_sg" {
  source           = "./modules/compute"
  project_id       = equinix_metal_project.anycast_test.id
  anycast_ip       = equinix_metal_reserved_ip_block.anycast_ip.address
  operating_system = "ubuntu_22_04"
  instance_type    = "c3.small.x86"
  metro            = "sg"
  compute_count    = "2"
  database_url     = var.database_url
}

module "compute_am" {
  source           = "./modules/compute"
  project_id       = equinix_metal_project.anycast_test.id
  anycast_ip       = equinix_metal_reserved_ip_block.anycast_ip.address
  operating_system = "ubuntu_22_04"
  instance_type    = "c3.small.x86"
  metro            = "am"
  compute_count    = "2"
  database_url     = var.database_url
}


module "compute_ny" {
  source           = "./modules/compute"
  project_id       = equinix_metal_project.anycast_test.id
  anycast_ip       = equinix_metal_reserved_ip_block.anycast_ip.address
  operating_system = "ubuntu_22_04"
  instance_type    = "c3.small.x86"
  metro            = "ny"
  compute_count    = "2"
  database_url     = var.database_url
}

output "anycast_ip" {
  value = equinix_metal_reserved_ip_block.anycast_ip.address
}
