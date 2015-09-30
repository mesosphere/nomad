variable "ssh_keys" {}

resource "atlas_artifact" "nomad-demo" {
  name    = "timfall/nomad-demo-gce"
  type    = "googlecompute.image"
  version = "latest"
}

provider "google" {
  account_file  = "${file("auth.json")}"
  project       = "massive-bliss-781"
  region        = "us-central1-c"
}

module "statsite" {
  source   = "./statsite"
  image    = "${atlas_artifact.nomad-demo-gce.id}"
}

module "servers" {
  source   = "./server"
  image    = "${atlas_artifact.nomad-demo.id}"
  count    = 1
  statsite = "${module.statsite.addr}"
}

module "clients" {
  source   = "./client"
  zone     = "us-central1-c"
  count    = 4
  image    = "${atlas_artifact.nomad-demo.id}"
  servers  = "${module.servers.addrs}"
}

/*module "clients-ams2" {
  source   = "./client"
  zone   = "ams2"
  count    = 500
  image    = "${atlas_artifact.nomad-demo.id}"
  servers  = "${module.servers.addrs}"
  ssh_keys = "${var.ssh_keys}"
}

module "clients-ams3" {
  source   = "./client"
  zone   = "ams3"
  count    = 500
  image    = "${atlas_artifact.nomad-demo.id}"
  servers  = "${module.servers.addrs}"
  ssh_keys = "${var.ssh_keys}"
}

module "clients-sfo1" {
  source   = "./client"
  zone   = "sfo1"
  count    = 500
  image    = "${atlas_artifact.nomad-demo.id}"
  servers  = "${module.servers.addrs}"
  ssh_keys = "${var.ssh_keys}"
}
*/
output "Nomad Servers" {
  value = "${join(" ", split(",", module.servers.addrs))}"
}

output "Statsite Server" {
  value = "${module.statsite.addr}"
}
