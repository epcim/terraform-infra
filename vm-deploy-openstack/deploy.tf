
variable "cluster_size" {
  default = 3
}

resource "openstack_compute_floatingip_v2" "management" {
  count      = "${var.cluster_size}"
  pool       = "${var.pool}"
  depends_on = ["openstack_networking_router_interface_v2.management"]
}

resource "openstack_compute_instance_v2" "ctl" {
  count      = "${var.cluster_size}"
  name            = "${format("ctl%02d", count.index+1)}"
  image_name      = "${var.image}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${var.tag_label}_tf"
  # mind other sec group: default, ...
  security_groups = ["${openstack_compute_secgroup_v2.ssh_only.name}"]

  network {
    uuid = "${openstack_networking_network_v2.management.id}"
  }
/*
  network {
    uuid = "${openstack_networking_network_v2.control.id}"
  }

  network {
    uuid = "${openstack_networking_network_v2.data.id}"
  }
*/

  #user_data = "${file("bootstrap.sh")}"

  #depends_on = ["openstack_compute_keypair_v2.terraform"]

  #availability_zone = "${var.zone}

}


resource "openstack_compute_floatingip_associate_v2" "terraform" {
  count      = "${var.cluster_size}"
  floating_ip = "${element(openstack_compute_floatingip_v2.management.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.ctl.*.id, count.index)}"

  provisioner "remote-exec" {
    connection {
      host = "${element(openstack_compute_floatingip_v2.management.*.address, count.index)}"
      user     = "${var.ssh_user_name}"
      private_key = "${file(var.ssh_key_file)}"
    }

    inline = [
      "sudo apt-get -y update",
    ]
  }

}


output "ctl_external_address" {
  value = "${openstack_compute_floatingip_v2.management.*.address}"
}







