
# Router – my router
# 192.168.219.0/24 – DHCP addresses 192.168.219.10-250, gateway – 192.168.219.254
# 192.168.220.0/23 – DHCP addresses 192.168.220.10-221.250, gateway – 192.168.221.254
# 192.168.222.0/24 – DHCP addresses 192.168.222.10-250, gateway – 192.168.222.254
# 192.168.223.0/24 – DHCP addresses 192.168.223.10-250, gateway – 192.168.223.254

variable "router_name" {
    description = "The name for external router"
    default  = "my-router"
}
variable "network_219" {
  type = "map"
  description = "Variables for the 219 Network"
  default = {
      network_name = "219"
      subnet_name = "219_Subnet"
      cidr = "192.168.219.0/24"
      gateway = "192.168.219.254"
      start_ip = "192.168.219.10"
      end_ip = "192.168.219.250"
  }
}

variable "network_220" {
  type = "map"
  description = "Variables for the 220 Network"
  default = {
      network_name = "220"
      subnet_name = "220_Subnet"
      cidr = "192.168.220.0/23"
      gateway = "192.168.221.254"
      start_ip = "192.168.220.10"
      end_ip = "192.168.221.250"
  }
}
variable "223" {
  type = "map"
  description = "Variables for the 223 Network"
  default = {
      network_name = "223"
      subnet_name = "223_Subnet"
      cidr = "192.168.223.0/24"
      gateway = "192.168.223.254"
      start_ip = "192.168.223.10"
      end_ip = "192.168.223.250"
  }
}

variable "224" {
  type = "map"
  description = "Variables for the 224 Network"
  default = {
      network_name = "224"
      subnet_name = "224_Subnet"
      cidr = "192.168.224.0/24"
      gateway = "192.168.224.254"
      start_ip = "192.168.224.10"
      end_ip = "192.168.224.250"
  }
}
