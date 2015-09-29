variable "ssh_keys" {}

resource "atlas_artifact" "nomad-demo" {
  name    = "timfalll/nomad"
  type    = "googlecompute.image"
  version = "latest"
}

module "statsite" {
  source   = "./statsite"
  ssh_keys = "${var.ssh_keys}"
}

module "servers" {
  source   = "./server"
  image    = "${atlas_artifact.nomad-demo.id}"
  ssh_keys = "${var.ssh_keys}"
  statsite = "${module.statsite.addr}"
}

module "clients-nyc3" {
  source   = "./client"
  region   = "nyc3"
  count    = 500
  image    = "${atlas_artifact.nomad-demo.id}"
  servers  = "${module.servers.addrs}"
  ssh_keys = "${var.ssh_keys}"
}

module "clients-ams2" {
  source   = "./client"
  region   = "ams2"
  count    = 500
  image    = "${atlas_artifact.nomad-demo.id}"
  servers  = "${module.servers.addrs}"
  ssh_keys = "${var.ssh_keys}"
}

module "clients-ams3" {
  source   = "./client"
  region   = "ams3"
  count    = 500
  image    = "${atlas_artifact.nomad-demo.id}"
  servers  = "${module.servers.addrs}"
  ssh_keys = "${var.ssh_keys}"
}

module "clients-sfo1" {
  source   = "./client"
  region   = "sfo1"
  count    = 500
  image    = "${atlas_artifact.nomad-demo.id}"
  servers  = "${module.servers.addrs}"
  ssh_keys = "${var.ssh_keys}"
}

output "Nomad Servers" {
  value = "${join(" ", split(",", module.servers.addrs))}"
}

output "Statsite Server" {
  value = "${module.statsite.addr}"
}
