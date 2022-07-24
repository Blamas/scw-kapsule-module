terraform {
  experiments      = [module_variable_optional_attrs]
  required_version = ">= 0.14"
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.2.3"
    }
  }
}
