variable "size" { default = "5" }
variable "zone" { default = "us-central1-c"}
variable "image" {}

resource "atlas_artifact" "statsite-gce" {
  name    = "timfall/nomad-demo-statsite-gce"
  type    = "googlecompute.image"
  version = "latest"
}

resource "google_compute_address" "statsite-address" {
  name = "nomad-address-${var.zone}-${var.count}"
  count         = 1
}

resource "google_compute_instance" "statsite" {
  name          = "nomad-statsite-${var.zone}-${count.index}"
  machine_type  = "n1-standard-4"
  count         = 1
  zone          = "${var.zone}"
  disk {
    image         = "${var.image}"
    size          = "${var.size}"
  }
  network_interface {
    network     = "nomad"
    access_config = {
      nat_ip = "${google_compute_address.statsite-address.address}"
    }
  }
  tags          = ["nomad"]

  provisioner "remote-exec" {
    inline = "sudo start statsite || true"
  }
}

output "addr" {
  value = "${google_compute_address.statsite-address.address}:8125"
}
