terraform {
  required_providers {
    vsphere = {
      # hashicorp/vsphere provider documentation: https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs
      source  = "hashicorp/vsphere"
      version = ">= 2.0.2"
    }
  }
}

provider "vsphere" {
  user                 = var.vc_user
  password             = var.vc_pass
  vsphere_server       = var.vc_host
  allow_unverified_ssl = true
}

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