# Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# -----------------------------------------------
# main.tf
# 
variable "vcn_use_existing" {
  description = "Boolean: whether to use an existing subnet (true) or create a new one (false)"
  default = false
}

variable "subnet_public_existing" {
  description = "The ID of the existing subnet, same format as oci_core_subnet.<subnet>.id"
  default = ""
}


# -----------------------------------------------------
# I have written everything so that VCN and subnet CIDRs
# have to be modified just here.
# I have not tested with other addresses than 10.0.0.0/16 and 10.0.0.0/24
# but that should work
# -----------------------------------------------------
variable "vcn_cidr" {
  description = "CIDR block for the VCN. Security rules are created after this."
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet. Security rules and IP addresses are created after this."
  default = "10.0.0.0/24"
}


locals {
  # get the subnet ID if it's a new subnet, or the variable otherwise
  public_subnet_id = var.vcn_use_existing ? var.subnet_public_existing : oci_core_subnet.public-subnet-podmanll[0].id

  # timestamps, handy to have unique names for the resources
  timestamp_full = timestamp()
  timestamp = replace(local.timestamp_full, "/[- TZ:]/", "")
}



# -----------------------------------------------------
# Create a dynamic TLS key for remote-exec provisioning
# -----------------------------------------------------
resource "tls_private_key" "provisioner_keypair" {
  algorithm   = "RSA"
  rsa_bits = "4096"
}


# -----------------------------------------------------
# Instantiate the podman host (OCI Compute) through the module.
# 
# There are many other variables that could be specified, just override them.
# (For the list, see modules/podman-host/variables.tf)
# -----------------------------------------------------
module "podman-host" {
  source                = "./modules/podman-host"
  availability_domain   = var.availability_domain_name
  compartment_id        = var.ociCompartmentOcid
  subnet_id             = local.public_subnet_id
  ssh_public_key        = tls_private_key.provisioner_keypair.public_key_openssh
  ssh_private_key       = tls_private_key.provisioner_keypair.private_key_pem
  subnet_cidr           = var.subnet_cidr
  vcn_cidr              = var.vcn_cidr
  resId                 = var.resId
  resUserPublicKey      = var.resUserPublicKey
}
