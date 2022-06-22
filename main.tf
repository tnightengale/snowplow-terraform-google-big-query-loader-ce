locals {
  module_name    = "snowplow-bigquery-loader-apps"
  module_version = "0.1.0"

  app_name    = "bigquery-loader-apps"
  app_version = "0.2.0"

  local_labels = {
    module_name    = local.module_name
    module_version = replace(local.module_version, ".", "-")
  }

  labels = merge(
    var.labels,
    local.local_labels
  )

  ssh_keys_metadata = <<EOF
    %{for v in var.ssh_key_pairs~}
      ${v.user_name}:${v.public_key}
    %{endfor~}
  EOF

  images_by_name = {
    for i in var.images : regex("snowplow[/]([a-z-]*):", i)[0] => {
      image = i
      path  = "${path.module}/templates/${regex("snowplow[/]([a-z-]*):", i)[0]}.sh.tmpl"
    }
  }
}


module "telemetry" {
  source  = "snowplow-devops/telemetry/snowplow"
  version = "0.2.0"

  count = var.telemetry_enabled ? 1 : 0

  user_provided_id = var.user_provided_id
  cloud            = "GCP"
  region           = var.region
  app_name         = local.app_name
  app_version      = local.app_version
  module_name      = local.module_name
  module_version   = local.module_version
}

# --- CE: Boot Image
data "google_compute_image" "ubuntu_20_04" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

# --- GCS: Set Up Google Cloud Storage
resource "google_storage_bucket" "dead_letter" {
  name          = "${var.name}-bq-loader-dead-letter"
  location      = var.region
  force_destroy = true
  versioning {
    enabled = false
  }
}

# --- BigQuery Dataset
resource "google_bigquery_dataset" "snowplow" {
  count      = var.dataset_config.create == true ? 1 : 0
  dataset_id = var.dataset_config.name
}

# --- IAM: Service Account Setup
resource "google_service_account" "sa" {
  account_id   = var.name
  display_name = "Snowplow BigQuery Loader service account - ${var.name}"
}

resource "google_project_iam_member" "sa_pubsub_viewer" {
  project = var.project_id
  role    = "roles/pubsub.viewer"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_member" "sa_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_member" "sa_pubsub_subscriber" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_member" "sa_logging_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_member" "sa_storage_object_viewer" {
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.sa.email}"
  project = var.project_id
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket = google_storage_bucket.dead_letter.name
  role   = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:${google_service_account.sa.email}"
  ]
}

locals {
  created_or_provided_dataset_id = var.dataset_config.create ? regex("[^/]+$", google_bigquery_dataset.snowplow[0].id) : var.dataset_config.name
  created_or_provided_table_id   = var.table_config.name
}

resource "google_bigquery_dataset_iam_member" "sa_bigquery_dataset_editor" {
  project    = var.project_id
  dataset_id = local.created_or_provided_dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.sa.email}"
  depends_on = [
    google_bigquery_dataset.snowplow
  ]
}

# --- PubSub: Set Up Subscriptions and Topics
resource "google_pubsub_topic" "types_topic" {
  name   = "${var.name}-types-topic"
  labels = local.labels
}

resource "google_pubsub_topic" "bad_types_topic" {
  name   = "${var.name}-bad-types-topic"
  labels = local.labels
}

resource "google_pubsub_topic" "failed_insert_topic" {
  name   = "${var.name}-failed-insert-topic"
  labels = local.labels
}

resource "google_pubsub_subscription" "input_subscription" {
  name                       = "${var.name}-input-subscription"
  topic                      = var.enriched_topic_id
  labels                     = local.labels
  message_retention_duration = "1200s"
  retain_acked_messages      = true
  ack_deadline_seconds       = 20
  enable_message_ordering    = false
  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }
}

resource "google_pubsub_subscription" "types_subscription" {
  name                       = "${var.name}-types-subscription"
  topic                      = google_pubsub_topic.types_topic.id
  labels                     = local.labels
  message_retention_duration = "1200s"
  retain_acked_messages      = true
  ack_deadline_seconds       = 20
  enable_message_ordering    = false
  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }
}

resource "google_pubsub_subscription" "failed_insert_subscription" {
  name                       = "${var.name}-failed-insert-subscription"
  topic                      = google_pubsub_topic.failed_insert_topic.id
  labels                     = local.labels
  message_retention_duration = "1200s"
  retain_acked_messages      = true
  ack_deadline_seconds       = 20
  enable_message_ordering    = false
  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }
}

# --- CE: Create Compute Instance Template
resource "google_compute_instance_template" "tpl" {
  name_prefix = local.module_name
  description = "This template is used to create Compute Engine instances, running the Snowplow BigQuery Loader apps."

  instance_description = var.name
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

    dynamic "access_config" {
      for_each = var.associate_public_ip_address ? [1] : []

      content {
        network_tier = "PREMIUM"
      }
    }
  }

  service_account {
    email  = google_service_account.sa.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    block-project-ssh-keys = var.ssh_block_project_keys
    ssh-keys               = local.ssh_keys_metadata
  }

  tags = [var.name]

  labels = local.labels

  lifecycle {
    create_before_destroy = true
  }
}

# --- Populate Terraform Templates to Use in Subsequent Steps
locals {

  enriched_topic_name       = regex("[^/]+$", var.enriched_topic_id)
  types_topic_name          = regex("[^/]+$", google_pubsub_topic.types_topic.id)
  bad_types_topic_name      = regex("[^/]+$", google_pubsub_topic.bad_types_topic.id)
  failed_inserts_topic_name = regex("[^/]+$", google_pubsub_topic.failed_insert_topic.id)

  input_sub_name          = regex("[^/]+$", google_pubsub_subscription.input_subscription.id)
  types_sub_name          = regex("[^/]+$", google_pubsub_subscription.types_subscription.id)
  failed_inserts_sub_name = regex("[^/]+$", google_pubsub_subscription.failed_insert_subscription.id)

  shared_hocon = templatefile("${path.module}/templates/config.hocon.tmpl", {
    dataset_id = local.created_or_provided_dataset_id
    table_id   = local.created_or_provided_table_id

    types_topic          = local.types_topic_name
    bad_types_topic      = local.bad_types_topic_name
    failed_inserts_topic = local.failed_inserts_topic_name

    input_sub          = local.input_sub_name
    types_sub          = local.types_sub_name
    failed_inserts_sub = local.failed_inserts_sub_name

    dead_letter_bucket_path = google_storage_bucket.dead_letter.url

    project_id = var.project_id
  })

  resolver = file("${path.module}/templates/resolver.json.tmpl")
}

# --- Local: Save Compiled config.hocon and resolver.json
resource "local_file" "config" {
  content  = local.shared_hocon
  filename = "${path.module}/templates/compiled/config.hocon"
}

resource "local_file" "resolver" {
  content  = local.resolver
  filename = "${path.module}/templates/compiled/resolver.json"
}

# --- CE: Create Apps from Compute Instance Template
resource "google_compute_instance_from_template" "snowplow_bq_app" {
  for_each = local.images_by_name
  name     = "${var.name}-${each.key}"
  zone     = var.zone

  source_instance_template = google_compute_instance_template.tpl.id

  metadata_startup_script = templatefile("${path.module}/templates/startup-script.sh.tmpl", {

    telemetry_script       = join("", module.telemetry.*.gcp_ubuntu_20_04_user_data)
    config_hocon_contents  = local.shared_hocon
    resolver_json_contents = local.resolver

    image_script = templatefile(each.value.path, {
      name             = each.key
      image            = each.value.image
      gcp_logs_enabled = var.gcp_logs_enabled
    })
  })

  depends_on = [
    google_bigquery_dataset_iam_member.sa_bigquery_dataset_editor
  ]
}
