resource "openstack_compute_keypair_v2" "terraform" {
  name       = "${var.tag_label}_tf"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_networking_network_v2" "management" {
  name           = "management"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "control" {
  name           = "control"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "data" {
  name           = "data"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "management" {
  name            = "control"
  network_id      = "${openstack_networking_network_v2.management.id}"
  cidr            = "10.10.10.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
  enable_dhcp     = "True"
}

resource "openstack_networking_subnet_v2" "control" {
  name            = "data"
  network_id      = "${openstack_networking_network_v2.control.id}"
  cidr            = "10.10.20.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
  enable_dhcp     = "True"
}

resource "openstack_networking_subnet_v2" "data" {
  name            = "data"
  network_id      = "${openstack_networking_network_v2.data.id}"
  cidr            = "10.10.30.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
  enable_dhcp     = "True"
}

resource "openstack_networking_router_v2" "management" {
  name             = "management"
  admin_state_up   = "true"
  external_network_id = "${var.external_gateway}"
}


resource "openstack_networking_router_interface_v2" "management" {
  router_id = "${openstack_networking_router_v2.management.id}"
  subnet_id = "${openstack_networking_subnet_v2.management.id}"
}

resource "openstack_compute_secgroup_v2" "ssh_only" {
  name        = "ssh_only"
  description = "Security group, allow all SSH ingress"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "ssh_and_web" {
  name        = "ssh_and_web"
  description = "Security group, allow all SSH ingress"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }


  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "all_open" {
  name        = "all_open"
  description = "Security group, allow all SSH ingress"

  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

