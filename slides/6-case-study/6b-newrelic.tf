data "newrelic_application" "dev" {
  name = "App - dev"
}

resource "newrelic_alert_policy" "dev" {
  name = "App - Dev"
}

locals {
  where_dev_host          = "(`hostname` LIKE '%app-dev%')"
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
