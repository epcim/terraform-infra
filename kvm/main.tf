
# list of hosts to be created, use 'for_each' on relevant resources
locals {
  microk8s = {
    "cmp2-kvm" = { osCode = "focal", octetIP = "12", vcpu=1, memoryMB=1024*2, incGB=60 },
    "cmp3-kvm" = { osCode = "focal", octetIP = "13", vcpu=1, memoryMB=1024*2, incGB=60 },
  }
  images =  {
    "focal" = {url = "https://cloud-images.ubuntu.com/focal/current", image = "focal-server-cloudimg-amd64.img" }
  }
}

# fetch the latest ubuntu release image from their mirrors
resource "null_resource" "images" {
  for_each = local.images

  provisioner "local-exec" {
    command = <<EOF
      test -e /var/lib/libvirt/images/${each.key}.img ||\
      curl -qsLo "/var/lib/libvirt/images/${each.key}.img" "${each.value.url}/${each.value.image}"
        
    EOF
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      echo "To cleanup imagers, run: 'rm -f /var/lib/libvirt/images/${each.key}*'"
    EOF
  }
}

resource "libvirt_volume" "os_image" {
  depends_on = [ null_resource.images ]
  for_each = local.microk8s

  name = "${each.key}.qcow2"
  pool = var.diskPool
  source = "/var/lib/libvirt/images/${each.value.osCode}.img"
  format = "qcow2"
}



# NOTE: THIS MIGHT NOT BE NECESSARY, workaround:
#https://github.com/dmacvicar/terraform-provider-libvirt/issues/546#issuecomment-612983090
# security_driver = "none" in /etc/libvirt/qemu.conf but followed by sudo systemctl restart libvirtd
resource "null_resource" "libvirt_permissions" {
  depends_on = [ libvirt_volume.os_image, libvirt_cloudinit_disk.cloudinit ]

  provisioner "local-exec" {
    command = <<EOF
      chown libvirt-qemu:libvirt -R /var/lib/libvirt
    EOF
  }
}

# since an Ubuntu cloud image is non-LVM, cannot extend rootFS with second disk
# so we extend using qemu-img, and then use the cloud_init file to grow the primary partition
resource "null_resource" "extend_primary_volume" {
  depends_on = [ null_resource.libvirt_permissions, libvirt_volume.os_image ]
  for_each = local.microk8s

  provisioner "local-exec" {
    command = <<EOF
      echo "going to wait 10 seconds before trying to increment disk size by ${each.value.incGB}GB"
      sleep 10
      poolPath=$(virsh pool-dumpxml ${var.diskPool} | grep -Po '<path>\K[^<]+')
      sudo qemu-img resize $poolPath/${each.key}.qcow2 +${each.value.incGB}G
    EOF
  }
}


# Use CloudInit ISO to add ssh-key to the instance
resource "libvirt_cloudinit_disk" "cloudinit" {
  for_each = local.microk8s

  name = "${each.key}-cloudinit.iso"
  pool = var.diskPool
  user_data = templatefile("cloud_init.cfg", {
            hostname = each.key,
            fqdn = "${each.key}.${var.dns_domain}",
            password = var.password,
            ssh_authorized_keys = var.ssh_authorized_keys
        })
  network_config = data.template_file.network_config[each.key].rendered
}

data "template_file" "network_config" {
  for_each = local.microk8s

  template = file("${path.module}/network_config_${var.ip_type}.cfg")
  vars = {
    domain = var.dns_domain
    prefixIP = var.prefixIP
    octetIP = each.value.octetIP
  }
}

# NOTE:, created by ansible
# uses bridged network from host
# https://www.desgehtfei.net/en/quick-start-kvm-libvirt-vms-with-terraform-and-ansible-part-1-2/
# resource "libvirt_network" "host-network" {
#   name = "host-network"
#   # nat|none|route|bridge
#   mode = "bridge"

#   # name of kvm bridge definition
#   # virsh net-list
#   bridge = "host-network"
#   autostart = true
# }
# ^^ require `service libvirtd restart`

# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  depends_on = [ null_resource.extend_primary_volume, null_resource.libvirt_permissions ]
  for_each = local.microk8s

  # domain name in libvirt, not hostname
  name = "${each.key}" #"-${var.prefixIP}.${each.value.octetIP}"
  memory = each.value.memoryMB
  vcpu = each.value.vcpu
  autostart = true

  disk { volume_id = libvirt_volume.os_image[each.key].id }

  network_interface {
     network_name = "host-network"
  }

  # DISABLED
  # # (primary ingress) give additional LoadBalancer NIC to first host
  # dynamic "network_interface" {
  #   for_each = index(keys(local.microk8s),each.key)==0 ? [1] : []
  #   content {
  #    network_name = "host-network"
  #    addresses = [var.additional_nic1 ]
  #   }
  # }
  # # (secondary ingress) give additional LoadBalancer NIC to first host
  # dynamic "network_interface" {
  #   for_each = index(keys(local.microk8s),each.key)==0 ? [1] : []
  #   content {
  #    network_name = "host-network"
  #    addresses = [ var.additional_nic2 ]
  #   }
  # }

  cloudinit = libvirt_cloudinit_disk.cloudinit[each.key].id

  # IMPORTANT
  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}

output "cmp2_network" {
  value = libvirt_domain.domain-ubuntu["cmp2-kvm"].network_interface[*]
}
output "hosts" {
  # output does not support 'for_each', so use zipmap as workaround
  value = zipmap( 
                values(libvirt_domain.domain-ubuntu)[*].name,
                values(libvirt_domain.domain-ubuntu)[*].vcpu
                )
}
