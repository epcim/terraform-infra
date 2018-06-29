
# https://github.com/terraform-providers/terraform-provider-openstack/issues/57

# LOAD BALANCER
resource "openstack_lb_loadbalancer_v2" "lb_1" {
	name = "TEST_LB"
	# Your Private network sub-net ID {source openrc; openstack network list}
  vip_subnet_id = "265fcfa3-eb18-4e2d-9e29-2f8f4506106f"
}

#LISTENER 1
resource "openstack_lb_listener_v2" "listener_1" {
  name = "listener01"
  description = "This is the listener description"
  protocol        = "HTTP"
  protocol_port   = 8080
  loadbalancer_id = "${ openstack_lb_loadbalancer_v2.lb_1.id }"
  region = "${var.region}"
}

#LISTENER 2
resource "openstack_lb_listener_v2" "listener_2" {
  name = "listener02"
  description = "This is the listener 2 description"
  protocol        = "HTTP"
  protocol_port   = 8081
  loadbalancer_id = "${ openstack_lb_loadbalancer_v2.lb_1.id }"
  region = "${var.region}"
}

#POOL 1
resource "openstack_lb_pool_v2" "pool_1" {
  name = "pool01"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${ openstack_lb_listener_v2.listener_1.id }"
  # loadbalancer_id = "${ openstack_lb_loadbalancer_v2.lb_1.id }"
  region = "${var.region}"

  persistence {
    type        = "APP_COOKIE"
    cookie_name = "Cookie_test"
  }
}

#POOL 2
resource "openstack_lb_pool_v2" "pool_2" {
  name = "pool02"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${ openstack_lb_listener_v2.listener_2.id }"
  # loadbalancer_id = "${ openstack_lb_loadbalancer_v2.lb_1.id }"
  region = "${var.region}"

  persistence {
    type        = "SOURCE_IP"
    cookie_name = "null"
  }
}


# -------------------------------------------------------

# Another example


resource "openstack_networking_network_v2" "test_network" {
  	name = "${var.environment_name}-network"
  	admin_state_up = "true"
}
resource "openstack_networking_port_v2" "lb_port" {
  	name = "test_lb_port"
  	network_id = "${openstack_networking_network_v2.test_network.id}"
  	security_group_ids = [
  		"${openstack_compute_secgroup_v2.test.id}"
  	]
  	admin_state_up = "true"
}
resource "openstack_lb_loadbalancer_v2" "test_lb" {
  	name = "${var.environment_name}-test-lb"
  	vip_subnet_id = "${openstack_networking_subnet_v2.test_subnet.id}"
}

resource "openstack_networking_floatingip_v2" "test_lb_vip" {
    pool = "${var.floatingip_pool}"
    port_id = "${openstack_lb_loadbalancer_v2.test_lb.vip_port_id}"
    depends_on = [
        "openstack_lb_loadbalancer_v2.test_lb",
    ]
}

resource "openstack_lb_listener_v2" "test_lb_listener" {
  	protocol = "HTTPS"
  	protocol_port = 443
  	loadbalancer_id =  "${openstack_lb_loadbalancer_v2.test_lb.id}"
}

resource "openstack_lb_pool_v2" "test_lb_pool" {
	name = "${var.environment_name}-test-pool"
  	protocol = "HTTPS"
  	lb_method = "ROUND_ROBIN"
  	listener_id =  "${openstack_lb_listener_v2.test_lb_listener.id}"
}

resource "openstack_lb_member_v2" "test_lb_members" {
	name = "${var.environment_name}-test-member"
  	count = "${var.number_of_test}"
  	pool_id = "${openstack_lb_pool_v2.test_lb_pool.id}"
  	subnet_id = "${openstack_networking_subnet_v2.test_subnet.id}"
  	address = "${element(openstack_compute_instance_v2.test.*.network.0.fixed_ip_v4, count.index)}"
  	protocol_port = 443
  	
  	depends_on = [
        "openstack_lb_loadbalancer_v2.test_lb",
    ]
}
