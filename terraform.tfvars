#          _____       _                      _____             __ _       
#         / ____|     | |                    / ____|           / _(_)      
#  __   _| (___  _ __ | |__   ___ _ __ ___  | |     ___  _ __ | |_ _  __ _ 
#  \ \ / /\___ \| '_ \| '_ \ / _ \ '__/ _ \ | |    / _ \| '_ \|  _| |/ _` |
#   \ V / ____) | |_) | | | |  __/ | |  __/ | |___| (_) | | | | | | | (_| |
#    \_/ |_____/| .__/|_| |_|\___|_|  \___|  \_____\___/|_| |_|_| |_|\__, |
#               | |                                                   __/ |
#               |_|                                                  |___/ 
vc_host   = "vcenter.ajlab.local"
esxi_host = "phys-esxi.ajlab.local"
dc        = "AJLAB"
datastore = "datastore1"
cluster   = "Compute"
folder    = "VxLAN Lab"    # This will also be used in the naming of all vSphere network objects (vSwitches & port groups). Any whitespace will be replaced with dashes in the object name.
mgmt_port_group  = "oob-mgmt-1"   # This should be an existing port group in vSphere 


#    ______      __                           _   _______                   _       _            
#   / __ \ \    / /\                         | | |__   __|                 | |     | |           
#  | |  | \ \  / /  \   ___    __ _ _ __   __| |    | | ___ _ __ ___  _ __ | | __ _| |_ ___  ___ 
#  | |  | |\ \/ / /\ \ / __|  / _` | '_ \ / _` |    | |/ _ \ '_ ` _ \| '_ \| |/ _` | __/ _ \/ __|
#  | |__| | \  / ____ \\__ \ | (_| | | | | (_| |    | |  __/ | | | | | |_) | | (_| | ||  __/\__ \
#   \____/   \/_/    \_\___/  \__,_|_| |_|\__,_|    |_|\___|_| |_| |_| .__/|_|\__,_|\__\___||___/
#                                                                    | |                         
#                                                                    |_|                         
nexus_switch_ova = "nexus9300v.9.3.8.ova"
router_template  = "8Kv-17.06.01a"
server_template  = "Rocky Linux 8.4 Minimal"


#    _____                           _____ _____ _______ 
#   / ____|                         / ____|  __ \__   __|
#  | (___   ___  ___ _   _ _ __ ___| |    | |__) | | |   
#   \___ \ / _ \/ __| | | | '__/ _ \ |    |  _  /  | |   
#   ____) |  __/ (__| |_| | | |  __/ |____| | \ \  | |   
#  |_____/ \___|\___|\__,_|_|  \___|\_____|_|  \_\ |_|   
# If not set to null, this will cause the script to create a SecureCRT folder (using var.folder) and add sessions for all the network elements based on console_telnet_port
securecrt_path = "/mnt/c/users/AJCRUZ/OneDrive - COMPUTACENTER/Secure CRT Config"


#   _           _        _____         _ _       _               
#  | |         | |      / ____|       (_) |     | |              
#  | |     __ _| |__   | (_____      ___| |_ ___| |__   ___  ___ 
#  | |    / _` | '_ \   \___ \ \ /\ / / | __/ __| '_ \ / _ \/ __|
#  | |___| (_| | |_) |  ____) \ V  V /| | || (__| | | |  __/\__ \
#  |______\__,_|_.__/  |_____/ \_/\_/ |_|\__\___|_| |_|\___||___/
# Values for eth ports should either be null or take the format access|trunk-{{link_name}}
# Every interface must have a port group defined, If null is used, the port group assigned to var.mgmt_port_group will be assigned
# IMPORTANT NOTES: The interface keys MUST begin with "eth" and be numbered sequentially starting with 1. Example: eth1
#   This is important for the provisioning script to be able to disconnect unused (null) interfaces.
#   Interfaces set to null will be disconnected so you don't get noisy CDP tables because every switch will be connected to every other switch.
#   Modifying interface quantities WILL cause a VM to be powered down, modified, and powered back up.
#   Modifying existing interface port groups will not cause a power cycle, but if it was previously disconnected it will not auto-connect.
n9ks = [
  {
    name                = "SPINE1"
    console_telnet_port = "2001"
    interfaces = {
      eth1 = "access-dc1-leaf1-2-spine1"
      eth2 = null
      eth3 = null
      eth4 = null
      eth5 = null
      eth6 = null
      eth7 = null
    }
  },
  {
    name                = "SPINE2"
    console_telnet_port = "2002"
    interfaces = {
      eth1 = "access-dc1-leaf1-2-spine2"
      eth2 = null
      eth3 = null
      eth4 = null
      eth5 = null
      eth6 = null
      eth7 = null
    }
  },
  {
    name                = "LEAF1"
    console_telnet_port = "2003"
    interfaces = {
      eth1 = "access-dc1-leaf1-2-spine1"
      eth2 = "access-dc1-leaf1-2-spine2"
      eth3 = "access-dc1-leaf1-2-v101svr1"
      eth4 = "trunk-dc1-leaf1-2-core1"
    }
  }
]


#   _           _       _____             _                
#  | |         | |     |  __ \           | |               
#  | |     __ _| |__   | |__) |___  _   _| |_ ___ _ __ ___ 
#  | |    / _` | '_ \  |  _  // _ \| | | | __/ _ \ '__/ __|
#  | |___| (_| | |_) | | | \ \ (_) | |_| | ||  __/ |  \__ \
#  |______\__,_|_.__/  |_|  \_\___/ \__,_|\__\___|_|  |___/
routers = [
  {
    name                = "CORE1"
    console_telnet_port = "2004"
    interfaces = {
      eth1 = null
      eth2 = "trunk-dc1-leaf1-2-core1"
      eth3 = null
    }
  }
]


#   _           _        _____                              
#  | |         | |      / ____|                             
#  | |     __ _| |__   | (___   ___ _ ____   _____ _ __ ___ 
#  | |    / _` | '_ \   \___ \ / _ \ '__\ \ / / _ \ '__/ __|
#  | |___| (_| | |_) |  ____) |  __/ |   \ V /  __/ |  \__ \
#  |______\__,_|_.__/  |_____/ \___|_|    \_/ \___|_|  |___/
servers = [
  {
    name       = "v101-svr1"
    domain     = "ajlab.local"
    eth0       = "access-dc1-leaf1-2-v101svr1"
    eth0_ip    = "10.1.1.101/24"
    gateway_ip = "10.1.1.1"
  }
]