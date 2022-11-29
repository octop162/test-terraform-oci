
resource "oci_core_vcn" "vcn1" {
  cidr_block     = "10.0.0.0/16"
  dns_label      = "vcn1"
  compartment_id = var.compartment_ocid
  display_name   = "vcn1"
}

resource "oci_core_internet_gateway" "test_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "testInternetGateway"
  vcn_id         = oci_core_vcn.vcn1.id
}

resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = oci_core_vcn.vcn1.default_route_table_id
  display_name               = "defaultRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.test_internet_gateway.id
  }
}

resource "oci_core_route_table" "route_table1" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn1.id
  display_name   = "routeTable1"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.test_internet_gateway.id
  }
}

resource "oci_core_default_dhcp_options" "default_dhcp_options" {
  manage_default_resource_id = oci_core_vcn.vcn1.default_dhcp_options_id
  display_name               = "defaultDhcpOptions"

  // required
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  // optional
  options {
    type                = "SearchDomain"
    search_domain_names = ["abc.com"]
  }
}

resource "oci_core_dhcp_options" "dhcp_options1" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn1.id
  display_name   = "dhcpOptions1"

  // required
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  // optional
  options {
    type                = "SearchDomain"
    search_domain_names = ["test123.com"]
  }
}

resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = oci_core_vcn.vcn1.default_security_list_id
  display_name               = "defaultSecurityList"

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }

  // allow outbound udp traffic on a port range
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "17" // udp
    stateless   = true

    udp_options {
      min = 319
      max = 320
    }
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  // allow inbound icmp traffic of a specific type
  ingress_security_rules {
    protocol  = 1
    source    = "0.0.0.0/0"
    stateless = true

    icmp_options {
      type = 3
      code = 4
    }
  }
}

// An AD based subnet will supply an Availability Domain
resource "oci_core_subnet" "public1" {
  availability_domain = data.oci_identity_availability_domain.ad1.name
  cidr_block          = "10.0.0.0/24"
  display_name        = "Public1"
  dns_label           = "Public1"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.vcn1.id
  security_list_ids   = [oci_core_vcn.vcn1.default_security_list_id]
  route_table_id      = oci_core_vcn.vcn1.default_route_table_id
  dhcp_options_id     = oci_core_vcn.vcn1.default_dhcp_options_id
}

resource "oci_core_subnet" "private1" {
  availability_domain       = data.oci_identity_availability_domain.ad1.name
  cidr_block                = "10.0.1.0/24"
  display_name              = "Private1"
  dns_label                 = "Private1"
  compartment_id            = var.compartment_ocid
  vcn_id                    = oci_core_vcn.vcn1.id
  security_list_ids         = [oci_core_vcn.vcn1.default_security_list_id]
  route_table_id            = oci_core_vcn.vcn1.default_route_table_id
  dhcp_options_id           = oci_core_vcn.vcn1.default_dhcp_options_id
  prohibit_internet_ingress = true
}

resource "oci_core_subnet" "public2" {
  availability_domain = data.oci_identity_availability_domain.ad2.name
  cidr_block          = "10.0.2.0/24"
  display_name        = "Public2"
  dns_label           = "Public2"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.vcn1.id
  security_list_ids   = [oci_core_vcn.vcn1.default_security_list_id]
  route_table_id      = oci_core_vcn.vcn1.default_route_table_id
  dhcp_options_id     = oci_core_vcn.vcn1.default_dhcp_options_id
}

resource "oci_core_subnet" "private2" {
  availability_domain       = data.oci_identity_availability_domain.ad2.name
  cidr_block                = "10.0.3.0/24"
  display_name              = "Private2"
  dns_label                 = "Private2"
  compartment_id            = var.compartment_ocid
  vcn_id                    = oci_core_vcn.vcn1.id
  security_list_ids         = [oci_core_vcn.vcn1.default_security_list_id]
  route_table_id            = oci_core_vcn.vcn1.default_route_table_id
  dhcp_options_id           = oci_core_vcn.vcn1.default_dhcp_options_id
  prohibit_internet_ingress = true
}
