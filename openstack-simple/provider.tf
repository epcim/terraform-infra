
provider "openstack" {
  user_name   = "${var.openstack_username}"
  password    = "${var.openstack_pasword}"
  tenant_name = "${var.openstack_tenant}"
  domain_name = "${var.openstack_domain}"
  auth_url    = "${var.openstack_auth_url}"
  region      = "${var.openstack_region}"
}
