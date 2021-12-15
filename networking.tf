# To determine the amount of access and trunk port groups to create we do the following:
# 1. Create a flattened list of all switch ports defined (exclude null ports) - local.sw_ports
# 2. Create a flattened list of all router ports defined (exclude null ports) - local.rtr_ports
# 3. Concatenate the two lists and filter only the access ports - local.access_ports
# 4. Concatenate the two lists and filter only the trunk ports - local.trunk_ports
# Now we can use the len() function to dertermne how many of each type we need to create in vSphere
locals {
  sw_ports = flatten([
    for sw in var.n9ks : [
      for int, pg in sw.interfaces : [
        pg
      ] if pg != null
    ]
  ])
}

locals {
  rtr_ports = flatten([
    for rtr in var.routers : [
      for int, pg in rtr.interfaces : [
        pg
      ] if pg != null
    ]
  ])
}

locals {
  access_ports = [
    for port in distinct(concat(local.sw_ports,local.rtr_ports)) : port if length(regexall("access-", port)) > 0
  ]
}

locals {
  trunk_ports = [
    for port in distinct(concat(local.sw_ports,local.rtr_ports)) : port if length(regexall("trunk-", port)) > 0
  ]
}

# Add One Virtual Standard Switch to be used with all lab access PGs
resource "vsphere_host_virtual_switch" "vss-access" {
  name                     = "tf-${lower(replace(var.folder, " ", "-"))}-access"
  host_system_id           = data.vsphere_host.host.id
  network_adapters         = []
  active_nics              = []
  standby_nics             = []
  allow_promiscuous        = true
  allow_forged_transmits   = true
  allow_mac_changes        = true
  mtu                      = 9000
  link_discovery_operation = "none"
}

# Add vSS Switches for trunk PGs (one switch per PG, otherwise CDP on the virtual switches is screwy)
resource "vsphere_host_virtual_switch" "vss-trunk" {
  count                    = length(local.trunk_ports)
  name                     = "tf-${lower(replace(var.folder, " ", "-"))}-trunk${count.index + 101}"
  host_system_id           = data.vsphere_host.host.id
  network_adapters         = []
  active_nics              = []
  standby_nics             = []
  allow_promiscuous        = true
  allow_forged_transmits   = true
  allow_mac_changes        = true
  mtu                      = 9000
  link_discovery_operation = "none"
}

# Add Access PGs
resource "vsphere_host_port_group" "access-pg" {
  depends_on = [
    vsphere_host_virtual_switch.vss-access
  ]
  count               = length(local.access_ports)
  name                = "tf-${lower(replace(var.folder, " ", "-"))}-access${count.index + 101}"
  host_system_id      = data.vsphere_host.host.id
  virtual_switch_name = "tf-${lower(replace(var.folder, " ", "-"))}-access"
  vlan_id             = count.index + 101
}

# Add Trunk PGs (one per "trunk vSS")
resource "vsphere_host_port_group" "trunk-pg" {
  depends_on = [
    vsphere_host_virtual_switch.vss-trunk
  ]
  count               = length(local.trunk_ports)
  name                = "tf-${lower(replace(var.folder, " ", "-"))}-trunk${count.index + 101}"
  host_system_id      = data.vsphere_host.host.id
  virtual_switch_name = "tf-${lower(replace(var.folder, " ", "-"))}-trunk${count.index + 101}"
  vlan_id             = 4095
}