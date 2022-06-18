output "bq_loader_apps" {
  description = "The compute instances created."
  value       = google_compute_instance_template.tpl[*]
}
