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
  bad_topic = var.bad_topic
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
      --output-template string      output template (default "<!-- BEGIN_TF_DOCS -->\n{{ .Content }}\n<!-- END_TF_DOCS -->")
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
