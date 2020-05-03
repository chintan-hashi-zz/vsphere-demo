terraform {
  backend "remote" {
    hostname     = "ptfe.this-demo.rocks"
    organization = "cgosalia-demo"

    workspaces {
      name = "vSphere-Demo"
    }
  }
}
