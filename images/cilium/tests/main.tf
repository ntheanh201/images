terraform {
  required_providers {
    oci = { source = "chainguard-dev/oci" }
  }
}

variable "digests" {
  description = "The digests to run tests over."
  type = object({
    agent             = string
    hubble-relay      = string
    hubble-ui         = string
    hubble-ui-backend = string
    operator          = string
  })
}

variable "chart_version" {
  description = "The version of the Cilium to install. This chooses the Helm chart"
  type        = string
  default     = "1.14.6"
}

resource "random_id" "suffix" {
  byte_length = 4
}

data "oci_exec_test" "operator-version" {
  script = "docker run --rm $IMAGE_NAME --version"
  digest = var.digests.operator
}

data "oci_exec_test" "cilium-install" {
  script          = "${path.module}/cilium-install.sh"
  digest          = var.digests.agent
  timeout_seconds = 1200
  env = [{
    name  = "AGENT_IMAGE"
    value = var.digests.agent
    }, {
    name  = "HUBBLE_RELAY_IMAGE"
    value = var.digests.hubble-relay
    }, {
    name  = "HUBBLE_UI_IMAGE"
    value = var.digests.hubble-ui
    }, {
    name  = "HUBBLE_UI_BACKEND_IMAGE"
    value = var.digests.hubble-ui-backend
    }, {
    name  = "OPERATOR_IMAGE"
    value = var.digests.operator
    }, {
    name  = "CHART_VERSION"
    value = var.chart_version
    }, {
    name  = "CLUSTER_NAME"
    value = "cilium-test-${random_id.suffix.hex}"
  }]
}
