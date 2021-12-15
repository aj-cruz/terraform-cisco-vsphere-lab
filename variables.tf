variable "vc_host" {
  description = "vCenter hostname or IP"
  type        = string
}

variable "vc_user" {
  description = "vCenter Admin Username"
  type        = string
}

variable "vc_pass" {
  description = "vCenter Admin Password"
  type        = string
  sensitive   = true
}

variable "esxi_host" {
  description = "ESXi host on which to perform actions"
  type        = string
}

variable "dc" {
  description = "The Datacenter in vCenter where objects will be created"
  type        = string
}

variable "datastore" {
  description = "The datastore in vSphere where objects will be created"
  type        = string
  default     = "datastore1"
}

variable "cluster" {
  description = "The vSphere Cluster to place resources"
  type        = string
}

variable "folder" {
  description = "The vSphere folder where VMs will be created"
  type        = string
}

variable "mgmt_port_group" {
  type = string
}

variable "nexus_switch_ova" {
  type = string
}

variable "router_template" {
  type = string
}

variable "server_template" {
  type = string
}

variable "n9ks" {
  type = list(object({
    name                = string
    console_telnet_port = string
    interfaces          = map(string)
  }))
}

variable "routers" {
  type = list(object({
    name                = string
    console_telnet_port = string
    interfaces          = map(string)
  }))
}

variable "servers" {
  type = list(map(string))
}

variable "securecrt_path" {
  type = string
}