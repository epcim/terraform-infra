
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
  key_pair        = "${var.tag_namespace}_${var.tag_env}_tf"
  # mind other sec group: default, ...
  security_groups = ["${openstack_compute_secgroup_v2.ssh_only.name}"]
  depends_on = ["openstack_compute_floatingip_v2.management"]

  # to be consumed by https://github.com/hashicorp/go-discover/blob/master/test/tf/os/main.tf
  metadata {
    habitat = "sup"
  }

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

}


resource "openstack_compute_floatingip_associate_v2" "terraform" {
  count      = "${var.cluster_size}"
  floating_ip = "${element(openstack_compute_floatingip_v2.management.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.ctl.*.id, count.index)}"


}

resource "null_resource" "hab-svc" {

  depends_on = ["openstack_compute_floatingip_associate_v2.terraform"]

  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${element(openstack_compute_floatingip_v2.management.*.address, count.index)}"
    private_key = "${file("${var.ssh_key_file}")}"
  }

  # upload certificates
  provisioner "local-exec" {
    command = "mkdir ./tmp; cp -v ./cfssl/*vault*.pem ./tmp"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /hab/svc/etcd/files",
      "sudo mkdir -p /hab/svc/vault/files",
      "sudo chown -R $USER.$USER /hab"
    ]
  }
  provisioner "file" {
    source      = "./tmp/"
    destination = "/hab/svc/etcd/files"
  }
  provisioner "file" {
    source      = "./tmp/"
    destination = "/hab/svc/vault/files"
  }

  provisioner "habitat" {
    #peer = "${openstack_compute_instance_v2.ctl.0.private_ip}"
    #peer = "${element(openstack_compute_floatingip_v2.management.*.address, count.index)}"
    #peer = "${element(openstack_compute_floatingip_v2.management.*.address, count.index)}"
    #peer = "${openstack_compute_floatingip_v2.management.0.address}"
    peer = "${openstack_compute_instance_v2.ctl.0.access_ip_v4}"
    use_sudo = true
    service_type = "systemd"
    permanent_peer = true

    service {
      name      = "epcim/etcd"
      topology  = "leader"
      user_toml = "${file("../etcd/env/vault-etcd.${var.tag_env}.toml")}"
      channel   = "unstable"
      strategy  = "rolling"
      group     = "${var.tag_namespace}"
    }

    service {
      name      = "epcim/vault"
      topology  = "leader"
      user_toml = "${file("../vault/env/default.${var.tag_env}.toml")}"
      channel   = "unstable"
      binds     = ["storage:etcd.${var.tag_namespace}"]
      strategy  = "at-once"
      #strategy  = "rolling"
      group     = "${var.tag_namespace}"
    }

    #service {
    #  name      = "epcim/consul"
    #  topology  = "leader"
    #  user_toml = "${file("../etcd/env/consul.${var.tag_env}.toml")}"
    #  channel   = "unstable"
    #  strategy  = "rolling"
    #}
  }

  provisioner "remote-exec" {
  # connection {
  #   host = "${element(openstack_compute_floatingip_v2.management.*.address, count.index)}"
  #   user     = "${var.ssh_user_name}"
  #   private_key = "${file(var.ssh_key_file)}"
  # }

   inline = [
     "sudo apt-get -y update",
   ]
  }

}


output "ctl_external_address" {
  value = "${openstack_compute_floatingip_v2.management.*.address}"
}

output "ctl_management_address" {
  # management
  # .network.0.fixed_ip_v4
  value = "${openstack_compute_instance_v2.ctl.*.access_ip_v4}"
}

#output "ctl_control_address" {
#  value = "${openstack_compute_instance_v2.ctl.*.network.1.fixed_ip_v4}"
#}





