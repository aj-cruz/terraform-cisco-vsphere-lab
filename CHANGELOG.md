# 0.2.0 (December 17, 2021)
**UPDATES**
- Added variable validation to VM interfaces to make sure interfaces are either null, begin with "access-" or begin with "trunk-"
- Changed the port group creation logic so that sequential IDs are no longer required. After the "access-" or "trunk-" any arbitrary string can be used as a link identifier and will be used in the naming of the port group

# 0.1.1 (December 15, 2021)
**PROJECT STRUCTURE UPDATE**
- Moved all variables to **variables.tf**
- renamed **lab-variables.auto.tfvars** to **terraform.tfvars**

# 0.1.0 (December 14, 2021)
- Initial release