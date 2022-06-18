
variable "prefix" {
  description = "Will be prefixed to all resource names. Use to easily identify the resources created"
  type        = string
  default     = "snowplow"
}

variable "region" {
  description = "The name of the region to deploy within"
  type        = string
}

variable "network" {
  description = "The name of the network to deploy within"
  type        = string
}

variable "subnetwork" {
  description = "The name of the sub-network to deploy within; if populated will override the 'network' setting"
  type        = string
  default     = ""
}

variable "machine_type" {
  description = "The machine type to use"
  type        = string
  default     = "e2-micro"
}

variable "ssh_ip_allowlist" {
  description = "The list of CIDR ranges to allow SSH traffic from"
  type        = list(any)
  default     = [""]
}

variable "ssh_block_project_keys" {
  description = "Whether to block project wide SSH keys"
  type        = bool
  default     = true
}

variable "ssh_key_pairs" {
  description = "The list of SSH key-pairs to add to the servers"
  default     = []
  type = list(object({
    user_name  = string
    public_key = string
  }))
}

variable "ubuntu_20_04_source_image" {
  description = "The source image to use which must be based of of Ubuntu 20.04; by default the latest community version is used"
  default     = ""
  type        = string
}

variable "labels" {
  description = "The labels to append to this resource"
  default     = {}
  type        = map(string)
}

variable "gcp_logs_enabled" {
  description = "Whether application logs should be reported to GCP Logging"
  default     = true
  type        = bool
}

variable "images" {
  description = <<EOH
  The docker images with version tag to deploy on Compute Engine's instances. See here for details:
  https://docs.snowplowanalytics.com/docs/pipeline-components-and-applications/loaders-storage-targets/bigquery-loader/

  The default is to launch all three apps: 'Stream Loader', 'Mutator' and 'Repeater'.
  EOH
  type        = list(string)
  default = [
    "snowplow/snowplow-bigquery-streamloader:1.3.0",
    "snowplow/snowplow-bigquery-loader:1.3.0",
    "snowplow/snowplow-bigquery-mutator:1.3.0"
  ]
}

variable "service_account_email" {
  description = "A service account email to create the compute instances."
  type        = string
}

variable "enriched_sub" {
  description = "The pubsub subscription to read enriched messages from."
  type        = string
}

variable "bad_topic" {
  description = "The pubsub topic to contain failed messages of inserts in BigQuery."
  type        = string
}

variable "types_sub" {
  description = "The pubsub subscription for all the unique self describing json schemas which have been encountered to load into bigquery."
  type        = string
}

variable "types_topic" {
  description = "The pubsub topic for all the unique self describing json schemas which have been encountered to load into bigquery."
  type        = string
}

variable "failed_inserts_sub" {
  description = "The pubsub subscription for failed inserts."
  type        = string
}

variable "failed_inserts_topic" {
  description = "The pubsub topic for failed inserts."
  type        = string
}

variable "dead_letter_bucket_path" {
  description = "The uri for the Google Cloud Storage bucket, where failed inserts are dead lettered."
  type        = string
}

variable "tags" {
  description = "The tags to apply to the created resources."
  type        = list(string)
}
