variable "count" {}
variable "image" {}
variable "zone" { default = "us-central1-c"}
variable "size" { default = "10" }
variable "servers" {}
variable "ssh_keys" {}

  provider "google" "nomad-demo" {
    account_file  = "${file("auth.json")}"
    project       = "massive-bliss-781"
    region        = "us-central1-c"
  }

resource "template_file" "client_config" {
  filename = "${path.module}/client.hcl.tpl"
  vars {
    datacenter = "${var.zone}"
    servers    = "${split(",", var.servers)}"
  }
}

resource "google_compute_instance" "client" {
  name          = "nomad-client-${count.index}"
  count         = "${var.count}"
  zone          = "${var.zone}"
  disk {
    image       = "${var.image}"
    size        = "${var.size}"
  }
  ssh_keys      = ["${split(",", var.ssh_keys)}"]
  machine_type  = "n1-standard-2"
  tags          = ["nomad"]


  provisioner "remote-exec" {
    inline = <<CMD
cat > /usr/local/etc/nomad/client.hcl <<EOF
${template_file.client_config.rendered}
EOF
CMD
  }

  provisioner "remote-exec" {
    inline = "sudo start nomad || sudo restart nomad"
  }
}
