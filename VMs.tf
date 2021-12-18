# Create the Lab folder in vSphere
resource "vsphere_folder" "labfolder" {
  path          = var.folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ooooo      ooo                                                  .oooooo..o                   o8o      .             oooo                           
# `888b.     `8'                                                 d8P'    `Y8                   `"'    .o8             `888                           
#  8 `88b.    8   .ooooo.  oooo    ooo oooo  oooo   .oooo.o      Y88bo.      oooo oooo    ooo oooo  .o888oo  .ooooo.   888 .oo.    .ooooo.   .oooo.o 
#  8   `88b.  8  d88' `88b  `88b..8P'  `888  `888  d88(  "8       `"Y8888o.   `88. `88.  .8'  `888    888   d88' `"Y8  888P"Y88b  d88' `88b d88(  "8 
#  8     `88b.8  888ooo888    Y888'     888   888  `"Y88b.            `"Y88b   `88..]88..8'    888    888   888        888   888  888ooo888 `"Y88b.  
#  8       `888  888    .o  .o8"'88b    888   888  o.  )88b      oo     .d8P    `888'`888'     888    888 . 888   .o8  888   888  888    .o o.  )88b 
# o8o        `8  `Y8bod8P' o88'   888o  `V88V"V8P' 8""888P'      8""88888P'      `8'  `8'     o888o   "888" `Y8bod8P' o888o o888o `Y8bod8P' 8""888P' 
resource "vsphere_virtual_machine" "Nexus-9Ks" {
  depends_on = [
    vsphere_host_port_group.access-pg,
    vsphere_host_port_group.trunk-pg,
    vsphere_folder.labfolder
  ]
  for_each = {
    for vm in var.n9ks : vm.name => vm
  }
  name                       = each.value.name
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  host_system_id             = data.vsphere_host.host.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  datacenter_id              = data.vsphere_datacenter.dc.id
  folder                     = var.folder
  num_cpus                   = data.vsphere_ovf_vm_template.n9k.num_cpus
  memory                     = data.vsphere_ovf_vm_template.n9k.memory
  scsi_controller_count      = 0
  firmware                   = data.vsphere_ovf_vm_template.n9k.firmware

  ovf_deploy {
    local_ovf_path    = "./ova-repo/${var.nexus_switch_ova}"
    disk_provisioning = "thin"
  }

  network_interface {
    network_id   = data.vsphere_network.mgmt.id
    adapter_type = "e1000"
  }

  dynamic "network_interface" {
    for_each = each.value.interfaces

    content {
      network_id   = network_interface.value == null ? data.vsphere_network.mgmt.id : (length(regexall("access-", network_interface.value)) > 0 ? data.vsphere_network.access-ports[network_interface.value].id : (length(regexall("trunk-", network_interface.value)) > 0 ? data.vsphere_network.trunk-ports[network_interface.value].id : (data.vsphere_network.mgmt.id)))
      adapter_type = "e1000"
    }
  }

  # The Terraform vsphere provider does not support adding serial devices to VMs. To get around this we use a local-exec provisioner and govc to do the following after the VM is created:
  # 1. Power down the VM
  # 2. Add a serial port
  # 3. Configure the serial port (Add a telnet URI)
  # 4. Power up the VM
  # IMPORTANT NOTE: You must have govc installed on the local machine running Terraform in order for this to work!
  provisioner "local-exec" {
    command = <<EOT
      govc vm.power -off=true '${var.folder}/${each.value.name}'
      govc device.serial.add -vm '${var.folder}/${each.value.name}'
      govc device.serial.connect -vm '${var.folder}/${each.value.name}' telnet://${var.esxi_host}:${each.value.console_telnet_port}
      %{for int_key, int in each.value.interfaces}
      %{if int == null}
      govc device.disconnect -vm '${var.folder}/${each.value.name}' ethernet-${trimprefix(int_key, "eth")}
      %{endif}
      %{endfor}
      govc vm.power -on=true '${var.folder}/${each.value.name}'
    EOT
  }

  # There appears to be an idempotency problem with this resource, when running apply a 2nd time it wants to change these resources, so we ignore them
  lifecycle {
    ignore_changes = [
      scsi_bus_sharing,
      scsi_type
    ]
  }
}


# ooooooooo.                             .                               
# `888   `Y88.                         .o8                               
#  888   .d88'  .ooooo.  oooo  oooo  .o888oo  .ooooo.  oooo d8b  .oooo.o 
#  888ooo88P'  d88' `88b `888  `888    888   d88' `88b `888""8P d88(  "8 
#  888`88b.    888   888  888   888    888   888ooo888  888     `"Y88b.  
#  888  `88b.  888   888  888   888    888 . 888    .o  888     o.  )88b 
# o888o  o888o `Y8bod8P'  `V88V"V8P'   "888" `Y8bod8P' d888b    8""888P' 
resource "vsphere_virtual_machine" "routers" {
  depends_on = [
    vsphere_host_port_group.access-pg,
    vsphere_host_port_group.trunk-pg,
    vsphere_folder.labfolder
  ]
  for_each = {
    for vm in var.routers : vm.name => vm
  }
  name                       = each.value.name
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  host_system_id             = data.vsphere_host.host.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  folder                     = var.folder
  num_cpus                   = 1
  memory                     = 4092
  guest_id                   = data.vsphere_virtual_machine.router_template.guest_id
  firmware                   = data.vsphere_virtual_machine.router_template.firmware
  shutdown_wait_timeout      = 1

  disk {
    label            = "disk0"
    size             = 8
    thin_provisioned = true
  }

  dynamic "network_interface" {
    for_each = each.value.interfaces

    content {
      network_id   = network_interface.value == null ? data.vsphere_network.mgmt.id : (length(regexall("access-", network_interface.value)) > 0 ? data.vsphere_network.access-ports[network_interface.value].id : (length(regexall("trunk-", network_interface.value)) > 0 ? data.vsphere_network.trunk-ports[network_interface.value].id : (data.vsphere_network.mgmt.id)))
      adapter_type = "vmxnet3"
    }
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.router_template.id
  }

  provisioner "local-exec" {
    command = <<EOT
      govc vm.power -off=true -force=true '${var.folder}/${each.value.name}'
      govc device.serial.connect -vm '${var.folder}/${each.value.name}' telnet://${var.esxi_host}:${each.value.console_telnet_port}
      %{for int_key, int in each.value.interfaces}
      %{if int == null}
      govc device.disconnect -vm '${var.folder}/${each.value.name}' ethernet-${trimprefix(int_key, "eth")}
      %{endif}
      %{endfor}
      govc vm.power -on=true '${var.folder}/${each.value.name}'
    EOT
  }
}


#  .oooooo..o                                                            
# d8P'    `Y8                                                            
# Y88bo.       .ooooo.  oooo d8b oooo    ooo  .ooooo.  oooo d8b  .oooo.o 
#  `"Y8888o.  d88' `88b `888""8P  `88.  .8'  d88' `88b `888""8P d88(  "8 
#      `"Y88b 888ooo888  888       `88..8'   888ooo888  888     `"Y88b.  
# oo     .d8P 888    .o  888        `888'    888    .o  888     o.  )88b 
# 8""88888P'  `Y8bod8P' d888b        `8'     `Y8bod8P' d888b    8""888P' 
resource "vsphere_virtual_machine" "servers" {
  depends_on = [
    vsphere_host_port_group.access-pg,
    vsphere_host_port_group.trunk-pg,
    vsphere_folder.labfolder
  ]
  for_each = {
    for svr in var.servers : svr.name => svr
  }
  name                       = each.value.name
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  host_system_id             = data.vsphere_host.host.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  folder                     = var.folder
  num_cpus                   = 1
  memory                     = 2048
  guest_id                   = data.vsphere_virtual_machine.server_template.guest_id
  scsi_bus_sharing           = data.vsphere_virtual_machine.server_template.scsi_bus_sharing
  scsi_type                  = data.vsphere_virtual_machine.server_template.scsi_type
  firmware                   = data.vsphere_virtual_machine.server_template.firmware

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.server_template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.server_template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.server_template.disks.0.thin_provisioned
  }

  network_interface {
    network_id   = data.vsphere_network.access-ports[each.value.eth0].id
    adapter_type = data.vsphere_virtual_machine.server_template.network_interface_types[0]
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.server_template.id

    customize {
      linux_options {
        host_name = each.value.name
        domain    = each.value.domain
      }
      network_interface {
        ipv4_address = split("/", each.value.eth0_ip)[0]
        ipv4_netmask = split("/", each.value.eth0_ip)[1]
      }
      ipv4_gateway = each.value.gateway_ip
    }
  }
}