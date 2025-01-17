terraform {
  required_providers {
    oci = { source = "chainguard-dev/oci" }
  }
}

variable "digest" {
  description = "The image digest to run tests over."
}

data "oci_string" "ref" { input = var.digest }

data "oci_exec_test" "version" {
  digest = var.digest
  script = <<EOF
    # We expect the command to fail, but want its output anyway.
    ( docker run --rm $IMAGE_NAME 2>&1 || true ) | grep "failed to create manager"
  EOF
}

data "oci_exec_test" "helm-install" {
  digest = var.digest
  script = "${path.module}/02-helm-install.sh"

  env {
    name  = "IMAGE_REGISTRY"
    value = data.oci_string.ref.registry
  }
  env {
    name  = "IMAGE_REPOSITORY"
    value = data.oci_string.ref.repo
  }
  env {
    name  = "IMAGE_TAG"
    value = data.oci_string.ref.pseudo_tag
  }
}
