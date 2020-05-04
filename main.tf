provider "vsphere" {
  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.dc_name
}

data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = "DatastoreCluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = "MainCluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "Ubuntu"
  datacenter_id = data.vsphere_datacenter.dc.id
}


resource "vsphere_folder" "cgosalia" {
  datacenter_id = data.vsphere_datacenter.dc.id
  path          = "cgosalia"
  type          = "vm"
  tags          = [vsphere_tag.tag_cgosalia.id]
}

resource "vsphere_virtual_machine" "test-vm" {
  name                 = "cgosalia-test-vm"
  resource_pool_id     = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  datastore_cluster_id = data.vsphere_datastore_cluster.datastore_cluster.id
  folder               = vsphere_folder.cgosalia.path
  tags                 = [ vsphere_tag.tag_cgosalia.id ]

  num_cpus = 4
  memory   = 4096
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "cgosalia-test-vm"
        domain    = "test.terraform"
      }

      network_interface {}
    }
  }
}

resource "vsphere_tag_category" "tag_category_owner" {
  name        = "Owner"
  description = "Owner of the resource."
  cardinality = "MULTIPLE"

  associable_types = [
    "VirtualMachine",
    "Folder"
  ]
}

resource "vsphere_tag" "tag_cgosalia" {
  name        = "cgosalia"
  category_id = vsphere_tag_category.tag_category_owner.id
  description = "Chintan Gosalia (chintan@hashicorp.com)"
}
