# terraform pagerduty docs: https://www.terraform.io/docs/providers/pagerduty/index.html

# Store the pagerduty-newrelic service keys in S3.
# When setting this up for the first time, you must ensure that the key is encrypted.
#
data "aws_s3_bucket_object" "pagerduty_low_priority_newrelic_service_key" {
  bucket = "some-bucket"
  key    = "app/terraform/pagerduty_low_priority_newrelic_service_key.txt"
}

resource "newrelic_alert_channel" "pagerduty_low_priority" {
  name = "App - Pagerduty Low Priority"
  type = "pagerduty"

  configuration = {
    service_key = "${data.aws_s3_bucket_object.pagerduty_low_priority_newrelic_service_key.body}"
  }
}

# Link alert policies to low- and high-priority channels.
#
resource "newrelic_alert_policy_channel" "dev_pagerduty_low_priority" {
  policy_id  = "${newrelic_alert_policy.dev.id}"
  channel_id = "${newrelic_alert_channel.pagerduty_low_priority.id}"
}
