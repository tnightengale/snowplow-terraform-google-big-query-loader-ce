output "bq_loader_apps" {
  description = "The compute instances created."
  value       = google_compute_instance_template.tpl[*]
}

output "templated_config_hocon" {
  value = local.shared_hocon
}

output "templated_resolver_json" {
  value = local.resolver
}

output "templated_start_up_scripts" {
  value = { for k in keys(local.images_by_name) : k => templatefile("${path.module}/templates/startup-script.sh.tmpl", {
    name                   = k
    image                  = local.images_by_name[k]
    config_hocon_contents  = local.shared_hocon
    resolver_json_contents = local.resolver

    telemetry_script = join("", module.telemetry.*.gcp_ubuntu_20_04_user_data)

    gcp_logs_enabled = var.gcp_logs_enabled
  }) }
}
