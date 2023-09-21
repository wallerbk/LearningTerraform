#variables
variable "token" {}
variable "root_pass" {}
terraform {
  required_providers {
    linode = {
        source   = "linode/linode"
        version  = "2.7.2"
    }
  }
}

provider "linode" {
    # Configuration options
    token       = var.token
}
resource "linode_instance" "example_instance" {
    label       = "example_instance"
    image       = "linode/ubuntu23.04"
    region      = "us-southeast"
    type        = "g6-nanode-1"
    root_pass   = var.root_pass

    provisioner "file" {
      source    = "setup_script.sh"
      destination = "/tmp/setup_script.sh"

      connection {
      type      = "ssh"
      host      = self.ip_address
      user      = "root"
      password  = var.root_pass
      }
    }
    provisioner "remote-exec" {
      inline = [ 
        "chmod +x /tmp/setup_script.sh",
        "tmp/setup_script.sh",
        "sleep 1"
       ]
      
      connection {
      type      = "ssh"
      host      = self.ip_address
      user      = "root"
      password  = var.root_pass
      }
    }
}

resource "linode_domain" "bearsystems_io" {
    domain      = "bearsystems.io"
    soa_email   = "bear@bearsystems.io"
    type        = "master"
}

resource "linode_domain_record" "example_domain_record"{
    domain_id   = linode_domain.bearsystems_io.id
    name        = "bearsystems.io"
    record_type = "A"
    target      = linode_instance.example_instance.ip_address
    ttl_sec     = 300
 }

resource "linode_firewall" "example_firewall" {
  label = "example_firewall_label"

    inbound {
      label     = "allow-http"
      action    = "ACCEPT"
      protocol  = "TCP"
      ports     = "80"
      ipv4      = ["0.0.0.0/0"]
    }

    inbound_policy  = "DROP"

    outbound_policy = "ACCEPT"

    linodes = [linode_instance.example_instance.id]
}

