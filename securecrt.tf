# Create the Lab folder in SecureCRT Sessions folder if var.securecrt_path is defined
# This is a total hack and not at all the intended use case for provisioners.
# Normally variables are not accessible to destroy provisioners. Only self, count, and each.keys are available.
# To get around this I use a single-item for_each loop and create a map with the key as the variable that I need to access for the destroy provisioner.
# Another unfortunate SecureCRT behavior is if your SecureCRT window is open when you run destroy, SecureCRT will re-create the folder automatically.
# The sessions will be gone, but the folder will get re-created. This is not a Terraform issue.
resource "null_resource" "create_securecrt_folder" {
  for_each = {
    for x in range(1) : "${var.securecrt_path}/Sessions/${var.folder}" => x if var.securecrt_path != null
  }
  provisioner "local-exec" {
    command = "mkdir '${each.key}'"
  }

  provisioner "local-exec" {
    command = "rm -rf '${each.key}'"    # var.securecrt_path & var.folder are not accessible by destroy provisioners, but each.key is
    when = destroy
  }
}

# Create the SecureCRT Sessions (INI files) for each switch & router
# I could not get the local_file resource to work with template rendering using templatefile(). Something funny happens to the rendered file when using templatefile().
# Even though it looks correct in Notepad, SecureCRT doens't like the file and the first time you try to open the device it strips most of the settings out including the hostname & port.
# So, I'm using a Python script instead to read a sample session ini file and write a new file line-by-line, replacing the hostname & telnet port when found.
resource "null_resource" "switch_securecrt_session" {
  depends_on = [
    null_resource.create_securecrt_folder
  ]

  for_each = {
    for vm in var.n9ks : vm.name => vm if var.securecrt_path != null
  }

  provisioner "local-exec" {
    command = "python3 ./provision_scripts/securecrt_session_file.py -t ./provision_scripts/securecrt_session_template.tpl -s '${var.securecrt_path}/Sessions/${var.folder}/${each.value.name}.ini' -i ${var.esxi_host} -p ${each.value.console_telnet_port}"
  }
}

resource "null_resource" "router_securecrt_session" {
  depends_on = [
    null_resource.create_securecrt_folder
  ]

  for_each = {
    for vm in var.routers : vm.name => vm if var.securecrt_path != null
  }

  provisioner "local-exec" {
    command = "python3 ./provision_scripts/securecrt_session_file.py -t ./provision_scripts/securecrt_session_template.tpl -s '${var.securecrt_path}/Sessions/${var.folder}/${each.value.name}.ini' -i ${var.esxi_host} -p ${each.value.console_telnet_port}"
  }
}