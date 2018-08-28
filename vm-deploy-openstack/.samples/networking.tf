# Declare variable for external network ID
variable "external_netid" {
  description = "Defines if the UUID of the external network"
  default = "c331d4d9-ce0a-472c-944b-347a4656970d3"
}


# for i in $(neutron net-list  | awk {'print $2}' | grep -); do  neutron net-show $i | grep "router:external | True"; done


resource "openstack_networking_router_v2" "my_router" {
  name = "${var.router_name}"
  external_gateway = "${var.TF_external_netid}"
}

resource "openstack_networking_network_v2" "219" {
  name = "${var.219["network_name"]}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "219_Subnet" {
  name = "${var.219["subnet_name"]}"
  network_id = "${openstack_networking_network_v2.219.id}"
  cidr = "${var.219["cidr"]}"
  gateway_ip = "${var.219["gateway"]}"
  enable_dhcp = "true"
  allocation_pools {
    start = "${var.219["start_ip"]}"
    end = "${var.219["end_ip"]}"
  }
}

resource "openstack_networking_router_interface_v2" "219_interface" {
  router_id = "${openstack_networking_router_v2.my_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.219_Subnet.id}"
}

resource "openstack_networking_network_v2" "220" {
  name = "${var.220["network_name"]}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "220_Subnet" {
  name = "${var.220["subnet_name"]}"
  network_id = "${openstack_networking_network_v2.220.id}"
  cidr = "${var.220["cidr"]}"
  gateway_ip = "${var.220["gateway"]}"
  enable_dhcp = "true"
  allocation_pools {
    start = "${var.220["start_ip"]}"
    end = "${var.220["end_ip"]}"
  }
}

resource "openstack_networking_router_interface_v2" "220_interface" {
  router_id = "${openstack_networking_router_v2.my_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.220_Subnet.id}"
}

resource "openstack_networking_network_v2" "222" {
  name = "${var.222["network_name"]}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "222_Subnet" {
  name = "${var.222["subnet_name"]}"
  network_id = "${openstack_networking_network_v2.222.id}"
  cidr = "${var.222["cidr"]}"
  gateway_ip = "${var.222["gateway"]}"
  enable_dhcp = "true"
  allocation_pools {
    start = "${var.222["start_ip"]}"
    end = "${var.222["end_ip"]}"
  }
}

resource "openstack_networking_router_interface_v2" "222_interface" {
  router_id = "${openstack_networking_router_v2.my_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.222_Subnet.id}"
}

resource "openstack_networking_network_v2" "223" {
  name = "${var.223["network_name"]}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "223_Subnet" {
  name = "${var.223["subnet_name"]}"
  network_id = "${openstack_networking_network_v2.223.id}"
  cidr = "${var.223["cidr"]}"
  gateway_ip = "${var.223["gateway"]}"
  enable_dhcp = "true"
  allocation_pools {
    start = "${var.223["start_ip"]}"
    end = "${var.223["end_ip"]}"
  }
}

resource "openstack_networking_router_interface_v2" "223_interface" {
  router_id = "${openstack_networking_router_v2.my_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.223_Subnet.id}"
}

resource "openstack_networking_network_v2" "224" {
  name = "${var.224["network_name"]}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "22_Subnet" {
  name = "${var.224["subnet_name"]}"
  network_id = "${openstack_networking_network_v2.224.id}"
  cidr = "${var.224["cidr"]}"
  gateway_ip = "${var.224["gateway"]}"
  enable_dhcp = "true"
  allocation_pools {
    start = "${var.224["start_ip"]}"
    end = "${var.224["end_ip"]}"
  }
}

resource "openstack_networking_router_interface_v2" "224_interface" {
  router_id = "${openstack_networking_router_v2.my_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.224_Subnet.id}"
}
