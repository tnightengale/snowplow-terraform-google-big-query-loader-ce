[![Release][release-image]][release] [![CI][ci-image]][ci] [![License][license-image]][license] [![Registry][registry-image]][registry] [![Source][source-image]][source]

# terraform-google-bigquery-loader-ce

A Terraform module which deploys the Snowplow BigQuery Loader apps on CE.  If you want to use a custom image for this deployment you will need to ensure it is based on top of Ubuntu 20.04.

## Usage

The Snowplow BigQuery Loader consists of three apps: StreamLoader, Mutator, and
Repeater. This module deploys all three by default to Compute Engine instances
on Google Cloud Platform.

```hcl
module "snowplow_bq_loader" {
  source  = "snowplow-bigquery-loader-apps"
  version = "0.1.0"

  prefix = var.prefix
  region = var.region
  network = var.network
  subnetwork = var.subnetwork
  machine_type = var.machine_type
  ssh_ip_allowlist = var.ssh_ip_allowlist
  ssh_block_project_keys = var.ssh_block_project_keys
  ssh_key_pairs = var.ssh_key_pairs
  ubuntu_20_04_source_image = var.ubuntu_20_04_source_image
  labels = var.labels
  gcp_logs_enabled = var.gcp_logs_enabled
  images = var.images
  service_account_email = var.service_account_email
  enriched_sub = var.enriched_sub
  bad_types_topic = var.bad_types_topic
  types_sub = var.types_sub
  types_topic = var.types_topic
  failed_inserts_sub = var.failed_inserts_sub
  failed_inserts_topic = var.failed_inserts_topic
  dead_letter_bucket_path = var.dead_letter_bucket_path
  tags = var.tags
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
A utility to generate documentation from Terraform modules in various output formats

Usage:
  terraform-docs [PATH] [flags]
  terraform-docs [command]

Available Commands:
  asciidoc    Generate AsciiDoc of inputs and outputs
  completion  Generate shell completion code for the specified shell (bash or zsh)
  help        Help about any command
  json        Generate JSON of inputs and outputs
  markdown    Generate Markdown of inputs and outputs
  pretty      Generate colorized pretty of inputs and outputs
  tfvars      Generate terraform.tfvars of inputs
  toml        Generate TOML of inputs and outputs
  version     Print the version number of terraform-docs
  xml         Generate XML of inputs and outputs
  yaml        Generate YAML of inputs and outputs

Flags:
  -c, --config string               config file name (default ".terraform-docs.yml")
      --footer-from string          relative path of a file to read footer from (default "")
      --header-from string          relative path of a file to read header from (default "main.tf")
  -h, --help                        help for terraform-docs
      --hide strings                hide section [all, data-sources, footer, header, inputs, modules, outputs, providers, requirements, resources]
      --lockfile                    read .terraform.lock.hcl if exist (default true)
      --output-check                check if content of output file is up to date (default false)
      --output-file string          file path to insert output into (default "")
      --output-mode string          output to file method [inject, replace] (default "inject")
      --output-template string      output template (default "<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_instance_from_template.snowplow_bq_app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_from_template) | resource |
| [google_compute_instance_template.tpl](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_pubsub_subscription.failed_insert_subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription.input_subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription.types_subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_topic.bad_types_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic.failed_insert_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic.types_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_storage_bucket.dead_letter](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_compute_image.ubuntu_20_04](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enriched_events_topic"></a> [enriched\_events\_topic](#input\_enriched\_events\_topic) | The pubsub topic to read enriched messages from. | `string` | n/a | yes |
| <a name="input_gcp_logs_enabled"></a> [gcp\_logs\_enabled](#input\_gcp\_logs\_enabled) | Whether application logs should be reported to GCP Logging | `bool` | `true` | no |
| <a name="input_images"></a> [images](#input\_images) | The docker images with version tag to deploy on Compute Engine's instances. See here for details:<br>  https://docs.snowplowanalytics.com/docs/pipeline-components-and-applications/loaders-storage-targets/bigquery-loader/<br><br>  The default is to launch all three apps: 'Stream Loader', 'Mutator' and 'Repeater'. | `list(string)` | <pre>[<br>  "snowplow/snowplow-bigquery-streamloader:1.3.0",<br>  "snowplow/snowplow-bigquery-loader:1.3.0",<br>  "snowplow/snowplow-bigquery-mutator:1.3.0"<br>]</pre> | no |
| <a name="input_labels"></a> [labels](#input\_labels) | The labels to append to this resource | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to use | `string` | `"e2-micro"` | no |
| <a name="input_network"></a> [network](#input\_network) | The name of the network to deploy within | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Will be prefixed to all resource names. Use to easily identify the resources created | `string` | `"snowplow"` | no |
| <a name="input_region"></a> [region](#input\_region) | The name of the region to deploy within | `string` | n/a | yes |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | A service account email to create the compute instances. | `string` | n/a | yes |
| <a name="input_ssh_block_project_keys"></a> [ssh\_block\_project\_keys](#input\_ssh\_block\_project\_keys) | Whether to block project wide SSH keys | `bool` | `true` | no |
| <a name="input_ssh_ip_allowlist"></a> [ssh\_ip\_allowlist](#input\_ssh\_ip\_allowlist) | The list of CIDR ranges to allow SSH traffic from | `list(any)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_ssh_key_pairs"></a> [ssh\_key\_pairs](#input\_ssh\_key\_pairs) | The list of SSH key-pairs to add to the servers | <pre>list(object({<br>    user_name  = string<br>    public_key = string<br>  }))</pre> | `[]` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | The name of the sub-network to deploy within; if populated will override the 'network' setting | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the created resources. | `list(string)` | n/a | yes |
| <a name="input_ubuntu_20_04_source_image"></a> [ubuntu\_20\_04\_source\_image](#input\_ubuntu\_20\_04\_source\_image) | The source image to use which must be based of of Ubuntu 20.04; by default the latest community version is used | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bq_loader_apps"></a> [bq\_loader\_apps](#output\_bq\_loader\_apps) | The compute instances created. |
<!-- END_TF_DOCS -->")
      --output-values               inject output values into outputs (default false)
      --output-values-from string   inject output values from file into outputs (default "")
      --read-comments               use comments as description when description is empty (default true)
      --recursive                   update submodules recursively (default false)
      --recursive-path string       submodules path to recursively update (default "modules")
      --show strings                show section [all, data-sources, footer, header, inputs, modules, outputs, providers, requirements, resources]
      --sort                        sort items (default true)
      --sort-by string              sort items by criteria [name, required, type] (default "name")
  -v, --version                     version for terraform-docs

Use "terraform-docs [command] --help" for more information about a command.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# Copyright and license

The Terraform Google Collector PubSub on Compute Engine project is Copyright 2021-2022 Snowplow Analytics Ltd.

Licensed under the [Apache License, Version 2.0][license] (the "License");
you may not use this software except in compliance with the License.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[release]: https://github.com/tnightengale/terraform-google-big-query-loader-ce/releases/latest
[release-image]: https://img.shields.io/github/v/release/snowplow-devops/terraform-google-collector-pubsub-ce

[ci]: https://github.com/tnightengale/terraform-google-big-query-loader-ce/actions?query=workflow%3Aci
[ci-image]: https://github.com/tnightengale/terraform-google-big-query-loader-ce/workflows/ci/badge.svg

[license]: https://www.apache.org/licenses/LICENSE-2.0
[license-image]: https://img.shields.io/badge/license-Apache--2-blue.svg?style=flat

<!-- [registry]: https://registry.terraform.io/modules/snowplow-devops/collector-pubsub-ce/google/latest
[registry-image]: https://img.shields.io/static/v1?label=Terraform&message=Registry&color=7B42BC&logo=terraform -->

[source]: https://github.com/snowplow-incubator/snowplow-bigquery-loader
[source-image]: https://img.shields.io/static/v1?label=Snowplow&message=BigQuery%20Loader&color=0E9BA4&logo=GitHub
