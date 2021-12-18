# Pull required vSphere data sources
data "vsphere_datacenter" "dc" {
  name = var.dc
}

data "vsphere_host" "host" {
  name          = var.esxi_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.cluster}/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_ovf_vm_template" "n9k" {
  name             = "nexus9000v-ovf"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  local_ovf_path   = "./ova-repo/${var.nexus_switch_ova}"
}

data "vsphere_virtual_machine" "router_template" {
  name          = var.router_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "server_template" {
  name          = var.server_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "mgmt" {
  name          = var.mgmt_port_group
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "access-ports" {
  depends_on = [
    vsphere_host_port_group.access-pg
  ]
  for_each = {
    for int in local.access_ports : int => int
  }
  name          = "tf-${lower(replace(var.folder, " ", "-"))}-${each.key}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "trunk-ports" {
  depends_on = [
    vsphere_host_port_group.trunk-pg
  ]
  for_each = {
    for int in local.trunk_ports : int => int
  }
  name          = "tf-${lower(replace(var.folder, " ", "-"))}-${each.key}"
  datacenter_id = data.vsphere_datacenter.dc.id
}