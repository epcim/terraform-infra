## Upload image to Glance
resource "null_resource" "my_img" {
  provisioner "local-exec" {
      command = "source /root/openstack.rc; glance image-create --name my_image
 --disk-format=qcow2 --container-format=ovf < /root/my-image.qcow2"
  }
}
