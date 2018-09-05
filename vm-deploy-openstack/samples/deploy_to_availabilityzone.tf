
variable "cluster_size_gpu" {
  default = 1
}

resource "openstack_compute_floatingip_v2" "gpu" {
  count      = "${var.cluster_size_gpu}"
  pool       = "${var.pool}"
  depends_on = ["openstack_networking_router_interface_v2.management"]
}

resource "openstack_compute_instance_v2" "gpu" {
  count      = "${var.cluster_size_gpu}"
  name            = "${format("gpu%02d", count.index+1)}"
  image_name      = "${var.image}"

  # FIXME, hardcoded flavor
  flavor_name     = "ml.medium.1xK40"
  key_pair        = "${var.tag_label}_tf"

  # mind other sec group: default, ...
  security_groups = ["${openstack_compute_secgroup_v2.ssh_and_web.name}"]

  network {
    uuid = "${openstack_networking_network_v2.management.id}"
  }

  #depends_on = ["openstack_compute_keypair_v2.terraform"]

  availability_zone = "withgpu"
}

resource "openstack_compute_floatingip_associate_v2" "gpu" {
  count      = "${var.cluster_size_gpu}"
  floating_ip = "${element(openstack_compute_floatingip_v2.gpu.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.gpu.*.id, count.index)}"

  provisioner "remote-exec" {
    connection {
      host = "${element(openstack_compute_floatingip_v2.gpu.*.address, count.index)}"
      user     = "${var.ssh_user_name}"
      private_key = "${file(var.ssh_key_file)}"
    }

    inline = [
      "sudo apt-get -y update",
    ]
  }

}


output "gpu_nodes" {
  description = "The public IP address for VMs"
  value = "${zipmap(openstack_compute_instance_v2.gpu.*.name, openstack_compute_floatingip_v2.gpu.*.address)}"
}



