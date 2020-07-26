variable "namespace" {
  description = "The Shaken Fist namespace to create"
}

variable "system_key" {
  description = "The key for the Shaken Fist system namespace"
}

variable "uniqifier" {
  description = "A unique string to prefix hostnames with"
}

// Create new namespace using Shaken Fist "system" privilege.
provider "shakenfist" {
  alias      = "system"
  server_url = "http://localhost:13000"
  namespace  = "system"
  key        = var.system_key
}

resource "shakenfist_namespace" "ci" {
  provider = shakenfist.system
  name     = var.namespace
}

resource "shakenfist_key" "cikey" {
  provider  = shakenfist.system
  namespace = shakenfist_namespace.ci.name
  keyname   = "robot"
  key       = "aMuop7IS6eithu9Ohqu4"
}

//
// Build CI resources in the new namespace.
//
provider "shakenfist" {
  server_url = "http://localhost:13000"
  namespace  = shakenfist_namespace.ci.name
  key        = shakenfist_key.cikey.key
}

resource "shakenfist_network" "internal" {
  name         = "internal"
  netblock     = "192.168.0.0/24"
  provide_dhcp = true
  provide_nat  = true
}

resource "shakenfist_instance" "sf_1" {
  name   = "sf-1"
  cpus   = 4
  memory = 4096
  disk {
    size = 50
    base = "ubuntu:18.04"
    bus  = "virtio"
    type = "disk"
  }
  networks = [
    "uuid=${shakenfist_network.internal.id},address=192.168.0.11",
  ]
}

resource "shakenfist_instance" "sf_2" {
  name   = "sf-2"
  cpus   = 4
  memory = 4096
  disk {
    size = 50
    base = "ubuntu:18.04"
    bus  = "virtio"
    type = "disk"
  }
  networks = [
    "uuid=${shakenfist_network.internal.id},address=192.168.0.12",
  ]
}

resource "shakenfist_instance" "sf_3" {
  name   = "sf-3"
  cpus   = 4
  memory = 4096
  disk {
    size = 50
    base = "ubuntu:18.04"
    bus  = "virtio"
    type = "disk"
  }
  networks = [
    "uuid=${shakenfist_network.internal.id},address=192.168.0.13",
  ]
}

resource "shakenfist_float" "sf_1_external" {
  interface = shakenfist_instance.sf_1.interfaces[0]
}

resource "shakenfist_float" "sf_2_external" {
  interface = shakenfist_instance.sf_2.interfaces[0]
}

resource "shakenfist_float" "sf_3_external" {
  interface = shakenfist_instance.sf_3.interfaces[0]
}

output "sf_1_external" {
  value = shakenfist_float.sf_1_external.ipv4
}

output "sf_2_external" {
  value = shakenfist_float.sf_2_external.ipv4
}

output "sf_3_external" {
  value = shakenfist_float.sf_3_external.ipv4
}

output "sf_1_internal" {
  value = "192.168.0.11"
}

output "sf_2_internal" {
  value = "192.168.0.12"
}

output "sf_3_internal" {
  value = "192.168.0.13"
}