
# DEPLOY

variable "image" {
  default = "ubuntu-16.04"
  #default = "FlatCar-Container-Linux"
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
variable "os_username" {
  description = "OpenStack auth user username"
  default     = "pmichalec"
}

variable "os_password" {
  description = "OpenStack auth user password"
  default     = "REDACTED"
}

variable "os_tenant" {
  description = "OpenStack auth project"
  default     = "pmichalec"
}

variable "os_project" {
  description = "OpenStack auth project"
  default     = "pmichalec"
}

variable "os_domain" {
  description = "OpenStack auth domain"
  default     = "default"
}

variable "os_region" {
  description = "OpenStack auth region"
  default     = "RegionOne"
}

variable "os_auth_url" {
  description = "OpenStack auth url/endpoint"
  default     = "https://lab.openstack.local:5000/v3"
}


# CUSTOM METADATA
variable "tag_namespace" {
  description = "Namespace tag for the tf deployment"
  default  = "vault-etcd"
}

variable "tag_env" {
  description = "Custom tag for the tf deployment env type (test, stage, prod)"
  default  = "test"
}
