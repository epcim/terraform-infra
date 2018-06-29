
# https://www.terraform.io/docs/modules/usage.html
# https://registry.terraform.io/

module "consul" {
  source  = "hashicorp/consul/openstack"
  version = "0.0.5"

  servers = 3
}
