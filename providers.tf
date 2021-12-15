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