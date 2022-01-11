variable "password" { default="linux" }
variable "dns_domain" { default="apealive.net"  }
variable "ip_type" { default = "static" }

# access
variable "ssh_authorised_keys" {
  type = list(string)
  default = []
}

# kvm standard default network
variable "prefixIP" { default = "172.31.1" }

# kvm disk pool name
variable "diskPool" { default = "default" }

# additional nics on microk8s-1
#variable "additional_nic1" { default="172.31.X.1X" }
#variable "additional_nic2" { default="172.31.X.1X" }

