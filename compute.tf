variable "instance_shape" {
  default = "VM.Standard.A1.Flex"
}

variable "instance_ocpus" {
  default = 1
}

variable "instance_shape_config_memory_in_gbs" {
  default = 1
}

variable "db_size" {
  default = "50" # size in GBs
}

variable "instance_image_ocid" {
  type = map(string)
  default = {
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaa26f5jvfjhdsdiy5pee3yiud7ersl7325cmbf4cltf7mqzczuz6bq"
  }
}

resource "oci_core_instance" "test_instance" {
  availability_domain = data.oci_identity_availability_domain.ad2.name
  compartment_id      = var.compartment_ocid
  display_name        = "TestInstance"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.public2.id
    display_name              = "Primaryvnic"
    assign_public_ip          = true
    assign_private_dns_record = true
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid[var.region]
  }

  metadata = {
    # ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(file("./userdata/bootstrap"))
  }

  preemptible_instance_config {
    preemption_action {
      type                 = "TERMINATE"
      preserve_boot_volume = false
    }
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_volume" "test_block_volume" {
  availability_domain = data.oci_identity_availability_domain.ad2.name
  compartment_id      = var.compartment_ocid
  display_name        = "TestBlock"
  size_in_gbs         = var.db_size
}

resource "oci_core_volume_attachment" "test_block_attach" {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.test_instance.id
  volume_id       = oci_core_volume.test_block_volume.id
  device          = "/dev/oracleoci/oraclevdb"
  use_chap        = true
}
