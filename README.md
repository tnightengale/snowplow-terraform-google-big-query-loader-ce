[![Release][release-image]][release] [![CI][ci-image]][ci] [![License][license-image]][license] [![Source][source-image]][source]

# snowplow-terraform-google-bigquery-loader-ce

A Terraform module which deploys the Snowplow BigQuery Loader apps on CE. If you want to use a custom image for this deployment you will need to ensure it is based on top of Ubuntu 20.04.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.50.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_telemetry"></a> [telemetry](#module\_telemetry) | snowplow-devops/telemetry/snowplow | 0.2.0 |

## Resources

| Name | Type |
|------|------|
| [google_bigquery_dataset.snowplow](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset) | resource |
| [google_bigquery_dataset_iam_member.sa_bigquery_dataset_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_compute_instance_from_template.snowplow_bq_app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_from_template) | resource |
| [google_compute_instance_template.tpl](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_project_iam_member.sa_logging_log_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.sa_pubsub_publisher](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.sa_pubsub_subscriber](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.sa_pubsub_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.sa_storage_object_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_subscription.failed_insert_subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription.input_subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription.types_subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_topic.bad_types_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic.failed_insert_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic.types_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_service_account.sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.dead_letter](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_binding.binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [local_file.config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.resolver](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [google_compute_image.ubuntu_20_04](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to assign a public ip address to this instance; if false this instance must be behind a Cloud NAT to connect to the internet | `bool` | `true` | no |
| <a name="input_dataset_config"></a> [dataset\_config](#input\_dataset\_config) | The dataset in which to load the Snowplow events. Created by default. | <pre>object({<br>    name   = string<br>    create = bool<br>  })</pre> | <pre>{<br>  "create": true,<br>  "name": "snowplow"<br>}</pre> | no |
| <a name="input_enriched_topic_id"></a> [enriched\_topic\_id](#input\_enriched\_topic\_id) | The pubsub topic to read enriched messages from. | `string` | n/a | yes |
| <a name="input_gcp_logs_enabled"></a> [gcp\_logs\_enabled](#input\_gcp\_logs\_enabled) | Whether application logs should be reported to GCP Logging | `bool` | `true` | no |
| <a name="input_images"></a> [images](#input\_images) | The docker images with version tag to deploy on Compute Engine's instances. See here for details:<br>  https://docs.snowplowanalytics.com/docs/pipeline-components-and-applications/loaders-storage-targets/bigquery-loader/<br><br>  The default is to launch all three apps: 'Stream Loader', 'Mutator' and 'Repeater'. | `list(string)` | <pre>[<br>  "snowplow/snowplow-bigquery-streamloader:1.3.2",<br>  "snowplow/snowplow-bigquery-repeater:1.3.2",<br>  "snowplow/snowplow-bigquery-mutator:1.3.2"<br>]</pre> | no |
| <a name="input_labels"></a> [labels](#input\_labels) | The labels to append to this resource | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to use | `string` | `"e2-micro"` | no |
| <a name="input_name"></a> [name](#input\_name) | Will be prefixed to all resource names. Use to easily identify the resources created. | `string` | `"loader"` | no |
| <a name="input_network"></a> [network](#input\_network) | The name of the network to deploy within. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The name of the region to deploy within. | `string` | n/a | yes |
| <a name="input_ssh_block_project_keys"></a> [ssh\_block\_project\_keys](#input\_ssh\_block\_project\_keys) | Whether to block project wide SSH keys | `bool` | `true` | no |
| <a name="input_ssh_ip_allowlist"></a> [ssh\_ip\_allowlist](#input\_ssh\_ip\_allowlist) | The list of CIDR ranges to allow SSH traffic from | `list(any)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_ssh_key_pairs"></a> [ssh\_key\_pairs](#input\_ssh\_key\_pairs) | The list of SSH key-pairs to add to the servers | <pre>list(object({<br>    user_name  = string<br>    public_key = string<br>  }))</pre> | `[]` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | The name of the sub-network to deploy within; if populated will override the 'network' setting. | `string` | `""` | no |
| <a name="input_table_config"></a> [table\_config](#input\_table\_config) | The table in which to load the Snowplow events. Created by default. | <pre>object({<br>    name                            = string<br>    load_timestamp_column           = string<br>    load_timestamp_column_partition = string<br><br>  })</pre> | <pre>{<br>  "load_timestamp_column": "load_tstamp",<br>  "load_timestamp_column_partition": null,<br>  "name": "events"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the created resources. | `list(string)` | `[]` | no |
| <a name="input_telemetry_enabled"></a> [telemetry\_enabled](#input\_telemetry\_enabled) | Whether or not to send telemetry information back to Snowplow Analytics Ltd | `bool` | `true` | no |
| <a name="input_ubuntu_20_04_source_image"></a> [ubuntu\_20\_04\_source\_image](#input\_ubuntu\_20\_04\_source\_image) | The source image to use which must be based of of Ubuntu 20.04; by default the latest community version is used | `string` | `""` | no |
| <a name="input_user_provided_id"></a> [user\_provided\_id](#input\_user\_provided\_id) | An optional unique identifier to identify the telemetry events emitted by this stack | `string` | `""` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone in which to deploy the instances. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bad_types_topic_name"></a> [bad\_types\_topic\_name](#output\_bad\_types\_topic\_name) | n/a |
| <a name="output_bq_loader_apps"></a> [bq\_loader\_apps](#output\_bq\_loader\_apps) | The compute instances created. |
| <a name="output_enriched_topic_name"></a> [enriched\_topic\_name](#output\_enriched\_topic\_name) | n/a |
| <a name="output_failed_inserts_sub_name"></a> [failed\_inserts\_sub\_name](#output\_failed\_inserts\_sub\_name) | n/a |
| <a name="output_failed_inserts_topic_name"></a> [failed\_inserts\_topic\_name](#output\_failed\_inserts\_topic\_name) | n/a |
| <a name="output_input_sub_name"></a> [input\_sub\_name](#output\_input\_sub\_name) | n/a |
| <a name="output_types_sub_name"></a> [types\_sub\_name](#output\_types\_sub\_name) | n/a |
| <a name="output_types_topic_name"></a> [types\_topic\_name](#output\_types\_topic\_name) | n/a |
<!-- END_TF_DOCS -->

# Copyright and license

The Terraform Google Collector PubSub on Compute Engine project is Copyright 2021-2022 Snowplow Analytics Ltd.

Licensed under the [Apache License, Version 2.0][license] (the "License");
you may not use this software except in compliance with the License.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[release]: https://github.com/tnightengale/snowplow-terraform-google-big-query-loader-ce/releases/latest
[release-image]: https://img.shields.io/github/v/release/tnightengale/snowplow-terraform-google-big-query-loader-ce

[ci]: https://github.com/tnightengale/snowplow-terraform-google-big-query-loader-ce/actions?query=workflow%3Aci
[ci-image]: https://github.com/tnightengale/snowplow-terraform-google-big-query-loader-ce/workflows/ci/badge.svg

[license]: https://www.apache.org/licenses/LICENSE-2.0
[license-image]: https://img.shields.io/badge/license-Apache--2-blue.svg?style=flat

<!-- [registry]: https://registry.terraform.io/modules/snowplow-devops/collector-pubsub-ce/google/latest
[registry-image]: https://img.shields.io/static/v1?label=Terraform&message=Registry&color=7B42BC&logo=terraform -->

[source]: https://github.com/snowplow-incubator/snowplow-bigquery-loader
[source-image]: https://img.shields.io/static/v1?label=Snowplow&message=BigQuery%20Loader&color=0E9BA4&logo=GitHub
