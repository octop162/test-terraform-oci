resource "oci_core_vcn" "vcn" {
  cidr_blocks    = ["10.0.0.0/16"]
  dns_label      = "vcn"
  display_name   = "vcn"
  compartment_id = var.compartment_ocid
}
