# terraform newrelic docs: https://www.terraform.io/docs/providers/newrelic/index.html

# Install and configure the newrelic plugin.
#
data "aws_s3_bucket_object" "newrelic_api_key" {
  bucket = "some-bucket"
  key    = "a-key/terraform/provider_newrelic_api_key.txt"
}

provider "newrelic" {
  api_key = "${data.aws_s3_bucket_object.newrelic_api_key.body}"
  version = "~> 1.0.1"
}

# Set up some alerts from a module.
data "newrelic_application" "dev" {
  name = "QPP Knowledge - test dev"
}

resource "newrelic_alert_policy" "dev" {
  name = "QPP Knowledge - test dev alert policy"
}

locals {
  where_dev_host          = "(`hostname` LIKE '%qpp-knowledge-share-test-app-dev%')"
  where_dev_host_and_node = "${local.where_dev_host} AND `commandName` = 'node'"
}

module "newrelic_alerts_dev_infra" {
  source         = "git@github.com:CMSgov/tf-newrelic//alerts/infra_base?ref=v1.0.0"
  policy_id      = "${newrelic_alert_policy.dev.id}"
  where          = "${local.where_dev_host}"
  high_ram_name  = "High Ram Usage (node)"
  high_ram_where = "${local.where_dev_host_and_node}"
}

module "newrelic_alerts_dev_apm_web" {
  source         = "git@github.com:CMSgov/tf-newrelic//alerts/apm_web_base?ref=v1.0.0"
  policy_id       = "${newrelic_alert_policy.dev.id}"
  newrelic_app_id = "${data.newrelic_application.dev.id}"
}
