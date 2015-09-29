variable "count" {}
variable "image" {}
variable "zone" { default = "us-central1-c"}
variable "size" { default = "10gb" }
variable "servers" {}
variable "ssh_keys" {}

resource "template_file" "client_config" {
  filename = "${path.module}/client.hcl.tpl"
  vars {
    datacenter = "${var.zone}"
    servers    = "${split(",", var.servers)}"
  }
}

resource "google_compute_instance" "client" {
  image         = "${var.image}"
  name          = "nomad-client-${count.index}"
  count         = "${var.count}"
  size          = "${var.size}"
  zone          = "${var.zone}"
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
