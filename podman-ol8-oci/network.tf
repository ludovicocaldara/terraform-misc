# Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# -----------------------------------------------
# Setup the VCN.
# -----------------------------------------------
resource "oci_core_vcn" "podmanll" {
  count          = var.vcn_use_existing ? 0 : 1
  cidr_block     = var.vcn_cidr
  dns_label      = "podmanllvcn${var.resId}"
  compartment_id = var.ociCompartmentOcid
  display_name   = "podmanll-vcn-${var.resId}"
  lifecycle {
    ignore_changes = [
      display_name,
    ]
  }
}

# -----------------------------------------------
# Setup the Internet Gateway
# -----------------------------------------------
resource "oci_core_internet_gateway" "podmanll-internet-gateway" {
  count          = var.vcn_use_existing ? 0 : 1
  compartment_id = var.ociCompartmentOcid
  display_name   = "podmanll-igw-${var.resId}"
  enabled        = "true"
  vcn_id         = oci_core_vcn.podmanll[0].id
}

# -----------------------------------------------
# Setup the Route Table
# -----------------------------------------------
resource "oci_core_route_table" "podmanll-public-rt" {
  count          = var.vcn_use_existing ? 0 : 1
  display_name   = "podmanll-route-${var.resId}"
  compartment_id = var.ociCompartmentOcid
  vcn_id         = oci_core_vcn.podmanll[0].id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.podmanll-internet-gateway[0].id
  }
}

# -----------------------------------------------
# Setup the Security List
# -----------------------------------------------
resource "oci_core_security_list" "podmanll-security-list" {
  count          = var.vcn_use_existing ? 0 : 1
  display_name   = "podmanll-seclist-${var.resId}"
  compartment_id = var.ociCompartmentOcid
  vcn_id         = oci_core_vcn.podmanll[0].id

  # -------------------------------------------
  # Egress: Allow everything
  # -------------------------------------------
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }


  # -------------------------------------------
  # Ingress protocol 6: TCP
  # -------------------------------------------

  # Allow SSH from everywhere
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow SQL*Net communication within the VCN only
  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr
    tcp_options {
      min = 1521
      max = 1531
    }
  }

  # ------------------------------------------
  # protocol 1: ICMP: allow explicitly from subnet and everywhere
  # ------------------------------------------
  ingress_security_rules {
    protocol = 1
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = 1
    source   = var.subnet_cidr
  }
}


# ---------------------------------------------
# Setup the Security Group
# ---------------------------------------------
resource "oci_core_network_security_group" "podmanll-network-security-group" {
  count          = var.vcn_use_existing ? 0 : 1
  compartment_id = var.ociCompartmentOcid
  vcn_id         = oci_core_vcn.podmanll[0].id
  display_name   = "podmanll-nsg-${var.resId}"
}

# ---------------------------------------------
# Setup the subnet
# ---------------------------------------------
resource "oci_core_subnet" "public-subnet-podmanll" {
  count             = var.vcn_use_existing ? 0 : 1
  cidr_block        = var.subnet_cidr
  display_name      = "podmanll-pubsubnet-${var.resId}"
  dns_label         = "pub${var.resId}"
  compartment_id    = var.ociCompartmentOcid
  vcn_id            = oci_core_vcn.podmanll[0].id
  route_table_id    = oci_core_route_table.podmanll-public-rt[0].id
  security_list_ids = [oci_core_security_list.podmanll-security-list[0].id]
}
