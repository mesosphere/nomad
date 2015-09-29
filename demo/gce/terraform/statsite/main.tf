variable "size" { default = "5" }
variable "zone" { default = "us-central1-c"}
variable "image" {}

provider "google" "nomad-demo" {
      account_file  = "${file("auth.json")}"
      project       = "massive-bliss-781"
      region        = "us-central1-c"
    }

resource "atlas_artifact" "statsite-gce" {
  name    = "timfall/nomad-demo-statsite-gce"
  type    = "googlecompute.image"
  version = "latest"
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
  tags          = ["nomad"]

  provisioner "remote-exec" {
    inline = "sudo start statsite || true"
  }
}

output "addr" {
  value = "${google_compute_instance.statsite.ipv4_address}:8125"
}
