resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_name
  cidr_blocks    = [var.vcn_cidr]
  dns_label      = "tfghvcn"
}
resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.main.id
  display_name = "${var.vcn_name}-igw"
  enabled = true
}
resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.main.id
  display_name = "${var.vcn_name}-public-routes"
  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id
  }
}
resource "oci_core_security_list" "main" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.main.id
  display_name = "${var.vcn_name}-security"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "all"
    stateless = false
  }
}
resource "oci_core_subnet" "public" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.main.id
  display_name = "${var.vcn_name}-public-subnet"
  cidr_block = var.subnet_cidr
  route_table_id = oci_core_route_table.public.id
  security_list_ids = [oci_core_security_list.main.id]
  prohibit_public_ip_on_vnic = false
  dns_label = "public"
}
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "~> 7.0"
    }
  }
  backend "local" { path = "terraform.tfstate" }
}
provider "oci" {
  region = var.region
}
variable "compartment_ocid" {
  description = "OCID of the OCI compartment where the VCN will be created."
  type = string
}
variable "region" {
  description = "OCI region identifier."
  type = string
}
variable "vcn_name" {
  description = "Name for the VCN."
  type = string
  default = "terraform-github-vcn"
}
variable "vcn_cidr" {
  description = "IPv4 CIDR block for the VCN."
  type = string
  default = "10.0.0.0/16"
}
variable "subnet_cidr" {
  description = "IPv4 CIDR block for the subnet."
  type = string
  default = "10.0.1.0/24"
}
output "vcn_id" {
  description = "OCID of the created VCN."
  value = oci_core_vcn.main.id
}
output "vcn_cidr" {
  description = "CIDR block assigned to the VCN."
  value = oci_core_vcn.main.cidr_blocks[0]
}
output "public_subnet_id" {
  description = "OCID of the created subnet."
  value = oci_core_subnet.public.id
}
