
provider "openstack" {
  user_name   = "${var.os_username}"
  password    = "${var.os_password}"
  tenant_name = "${var.os_tenant}"
  domain_name = "${var.os_domain}"
  auth_url    = "${var.os_auth_url}"
  region      = "${var.os_region}"
}
