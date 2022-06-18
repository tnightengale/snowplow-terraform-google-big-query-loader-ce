locals {
  module_name    = "snowplow-bigquery-loader-apps"
  module_version = "0.1.0"

  local_labels = {
    module_name    = local.module_name
    module_version = replace(local.module_version, ".", "-")
  }

  labels = merge(
    var.labels,
    local.local_labels
  )

  named_port_http = "http"
}

data "google_compute_image" "ubuntu_20_04" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

locals {
  config = templatefile("${path.module}/templates/config.hocon.tmpl", {
    enriched_sub = var.enriched_sub
    bad_topic    = var.bad_topic

    types_sub   = var.types_sub
    types_topic = var.types_topic

    failed_inserts_sub   = var.failed_inserts_sub
    failed_inserts_topic = var.failed_inserts_topic

    dead_letter_bucket_path = var.dead_letter_bucket_path
  })

  resolver = file("${path.module}/templates/resolver.json.tmpl")

  ssh_keys_metadata = <<EOF
    %{for v in var.ssh_key_pairs~}
      ${v.user_name}:${v.public_key}
    %{endfor~}
  EOF

  images_by_name = {
    for i in var.images : regex(".*[/]([a-z-]*):", i) => i
  }
}

resource "google_compute_instance_template" "tpl" {
  name_prefix = local.module_name
  description = "This template is used to create Compute Engine instances, running the Snowplow BigQuery Loader apps."

  instance_description = var.prefix
  machine_type         = var.machine_type

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = var.ubuntu_20_04_source_image == "" ? data.google_compute_image.ubuntu_20_04.self_link : var.ubuntu_20_04_source_image
    auto_delete  = true
    boot         = true
    disk_type    = "pd-standard"
    disk_size_gb = 10
  }

  # Note: Only one of either network or subnetwork can be supplied
  #       https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template#network_interface
  network_interface {
    network    = var.subnetwork == "" ? var.network : ""
    subnetwork = var.subnetwork

  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    block-project-ssh-keys = var.ssh_block_project_keys
    ssh-keys               = local.ssh_keys_metadata
  }

  tags = [var.prefix]

  labels = local.labels

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_from_template" "snowplow_bq_app" {
  for_each = local.images_by_name
  name     = "${var.prefix}-${each.key}"
  zone     = var.region

  source_instance_template = google_compute_instance_template.tpl.id

  metadata_startup_script = templatefile("${path.module}/templates/startup-script.sh.tmpl", {
    name                   = each.key
    image                  = each.value
    config_hocon_contents  = local.config
    resolver_json_contents = local.resolver
  })
}
