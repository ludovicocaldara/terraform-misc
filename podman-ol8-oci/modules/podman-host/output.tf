# Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# -------------------------------------------------------------------------------------
# Output the hostname label and public IP that will be printed by the terraform root 
# -------------------------------------------------------------------------------------
output "podmanhost_name_and_ip" {
  value = [oci_core_instance.podman_vm.hostname_label, oci_core_instance.podman_vm.public_ip]
}

