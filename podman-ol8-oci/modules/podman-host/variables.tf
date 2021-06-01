# Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# ----------------------------------------------------
# These variables are passed by the terraform root
# ----------------------------------------------------
variable "availability_domain" {}
variable "compartment_id" {}
variable "subnet_id" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}
variable "vcn_cidr" {}
variable "subnet_cidr" {}
variable "resId" {}
variable "resUserPublicKey" {}


# ----------------------------------------------------
# These variables are decent defaults
# ----------------------------------------------------
variable "vm_user" {
    description = "VM user to connect to (opc), don't change it unless you know what you are doing, it will break the lab"
    default = "opc"
}

variable "vm_shape" {
    description = "OCI Compute VM shape. Flex is the new default and it's pretty nice :-). Beware of your quotas, credits and limits if you plan to change it."
    default = "VM.Standard2.2"
}

variable "instance_ocpus" {
  description = "Number of OCPUs for the podman host"
  default = 4
}

variable "instance_memgb" {
  description = "GBs of memory for the podman host"
  default = 64
}

variable "podman_name" {
  description = "podman host name. Don't change it if you plan to follow the libe lab instructions."
  default = "podman"
}

variable "podman_disk_size" {
  description = "Size in GB for the disks to be added to podman host. "
  default = 200
}

variable "boot_volume_size_in_gbs" {
  description = "Size in GB for podman host compute instance boot volume"
  default = 128
}

