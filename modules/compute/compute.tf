# Andree Toonk
# Feb 23, 2019

variable "metro" {}
variable "project_id" {}
variable "compute_count" {}
variable "operating_system" {}
variable "instance_type" {}
variable "anycast_ip" {}
variable "database_url" {}
#variable bgp_password { }

terraform {
  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = "1.6.0"
    }
  }
}

resource "equinix_metal_bgp_session" "test" {
  count          = var.compute_count
  device_id      = equinix_metal_device.compute-server.*.id[count.index]
  address_family = "ipv4"
}

resource "equinix_metal_device" "compute-server" {
  hostname         = "${format("compute-%03d", count.index)}.${var.metro}"
  count            = var.compute_count
  plan             = var.instance_type
  metro            = var.metro
  operating_system = var.operating_system
  billing_cycle    = "hourly"
  project_id       = var.project_id
  user_data        = templatefile("${path.root}/scripts/ping-golf-setup.tftpl", { database_url = "${var.database_url}", anycast_ip = "${var.anycast_ip}" })
}
