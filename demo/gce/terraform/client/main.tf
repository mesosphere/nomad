variable "count" {}
variable "image" {}
variable "zone" { default = "us-central1-c"}
variable "size" { default = "10" }
variable "servers" {}

resource "template_file" "client_config" {
  filename     = "${path.module}/client.hcl.tpl"
  vars {
    datacenter = "${var.zone}"
    servers    = "${split(",", var.servers)}"
  }
}

resource "google_compute_address" "client-address" {
  name          = "nomad-address-${var.zone}-${var.count}"
  count         = "${var.count}"
}

resource "google_compute_instance" "client" {
  name          = "nomad-client-${count.index}"
  count         = "${var.count}"
  zone          = "${var.zone}"
  disk {
    image       = "${var.image}"
    size        = "${var.size}"
  }
  network_interface {
    network       = "nomad"
    access_config = {
      nat_ip      = "${element(google_compute_address.client-address.address, count.index)}"
    }
  }
  machine_type    = "n1-standard-2"
  tags            = ["nomad"]


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
