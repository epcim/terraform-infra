

#resource "openstack_blockstorage_volume_v3" "volume" {
#  count      = "${var.cluster_size}"
#  region      = "RegionOne"
#  name        = "${var.tag_label}_volume_${format("ctl%02d", count.index+1)}"
#  description = "Volume for ${var.tag_label} to be mounted at ctl node."
#  size        = 10
#}

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

  block_device {
    # ubuntu-bionic
    uuid                  = "c3a94bd1-2860-4d9d-ac09-57df25d9b715"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }

 # block_device {
 #   uuid                  = "${element(openstack_blockstorage_volume_v3.volume.*.id, count.index)}"
 #   source_type           = "volume"
 #   destination_type      = "volume"
 #   boot_index            = 1
 #   delete_on_termination = true
 # }

  block_device {
    boot_index            = -1
    volume_size           = 10
    source_type           = "blank"
    destination_type      = "volume"
    delete_on_termination = true
  }

}

# INDEPENDENT Vol ATTACH
# resource "openstack_compute_volume_attach_v2" "attached" {
#  compute_id = "${openstack_compute_instance_v2.myinstance.id}"
#  volume_id = "${openstack_blockstorage_volume_v2.myvol.id}"
# }








