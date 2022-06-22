output "bq_loader_apps" {
  description = "The compute instances created."
  value       = google_compute_instance_template.tpl[*]
}

output "enriched_topic_name" {
  value = local.enriched_topic_name
}

output "types_topic_name" {
  value = local.types_topic_name
}

output "bad_types_topic_name" {
  value = local.bad_types_topic_name
}

output "failed_inserts_topic_name" {
  value = local.failed_inserts_topic_name
}

output "input_sub_name" {
  value = local.input_sub_name
}

output "types_sub_name" {
  value = local.types_sub_name
}

output "failed_inserts_sub_name" {
  value = local.failed_inserts_sub_name
}
