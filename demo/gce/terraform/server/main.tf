variable "image" {}
variable "zone" { default = "us-central1-c"}
variable "size" { default = "10" }
variable "ssh_keys" {}
variable "statsite" {}
variable "count" {}

resource "google_compute_instance" "server" {
  name          = "nomad-server-${count.index}"
  machine_type  = "n1-standard-4"
  count         = 3
  zone          = "${var.zone}"
  disk {
    image       = "${var.image}"
    size        = "${var.size}"
  }
  ssh_keys      = ["${split(",", var.ssh_keys)}"]
  tags          = ["nomad"]

  provisioner "remote-exec" {
    inline = <<CMD
cat > /usr/local/etc/nomad/server.hcl <<EOF
datacenter = "${var.zone}"
server {
    enabled = true
    bootstrap_expect = 3
}
advertise {
    rpc = "${self.ipv4_address}:4647"
    serf = "${self.ipv4_address}:4648"
}
telemetry {
    statsite_address = "${var.statsite}"
    disable_hostname = true
}
EOF
CMD
  }

  provisioner "remote-exec" {
    inline = "sudo start nomad || sudo restart nomad"
  }
}

resource "null_resource" "server_join" {
  provisioner "local-exec" {
    command = <<CMD
join() {
  curl -X PUT ${google_compute_instance.server.0.ipv4_address}:4646/v1/agent/join?address=$1
}
join ${google_compute_instance.server.1.ipv4_address}
join ${google_compute_instance.server.2.ipv4_address}
CMD
  }
}

output "addrs" {
  value = "${join(",", google_compute_instance.server.*.ipv4_address)}"
}
