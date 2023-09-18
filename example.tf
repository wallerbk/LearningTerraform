terraform {
  required_providers {
    linode = {
        source = "linode/linode"
        version = "2.7.2"
    }
  }
}

provider "linode" {
    # Configuration options
    token = "4aaf8c58bf19148fd9809c1f9e6af65a0572c70bdbf5f9516b96b663fb4c35ee"
}
resource "linode_instance" "example_instance" {
    label       = "example_instance"
    image       = "linode/ubuntu23.04"
    region      = "us-southeast"
    type        = "g6-nanode-1"
    root_pass   = "39 Black#Cats"
}