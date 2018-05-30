
# DEPLOY

variable "image" {
  default = "ubuntu-16.04"
}

variable "flavor" {
  default = "m1.large"
}

variable "ssh_key_file" {
  default = "/home/pmichalec/.ssh/id_rsa_bootstrap_insecure"
}

variable "ssh_user_name" {
  default = "ubuntu"
}

variable "external_gateway" {
  default = "c3e550ff-b851-4216-99d8-53e56c341963"
}

variable "pool" {
  default = "public"
}


# PROVIDER
# FIXME, rename to os_username, ...
variable "openstack_username" {
  description = "OpenStack auth user username"
  default     = "pmichalec"
}

variable "openstack_password" {
  description = "OpenStack auth user password"
  default     = "REDACTED"
}

variable "openstack_project" {
  description = "OpenStack auth project"
  default     = "pmichalec"
}

variable "openstack_domain" {
  description = "OpenStack auth domain"
  default     = "default"
}

variable "openstack_region" {
  description = "OpenStack auth region"
  default     = "RegionOne"
}

variable "openstack_auth_url" {
  description = "OpenStack auth url/endpoint"
  default     = "https://lab.openstack.local:5000/v3"
}


# CUSTOM METADATA
# FIXME, rename to tag_label, tag_cluster, tag_env
variable "label" {
  description = "Custom tag for the tf deployment, used as label/preffix"
  default  = "pmichalec"
}

variable "cluster" {
  description = "Custom tag for the tf deployment cluster"
  default  = "habitat"
}

variable "tag_env" {
  description = "Custom tag for the tf deployment env"
  default  = "habitat"
}
