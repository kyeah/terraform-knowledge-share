# Define the storage backend for the state file.
terraform {
  backend "s3" {
    bucket         = "some-bucket"
    key            = "a-key/terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf_lock"
  }

  required_version = "~> 0.10.8"
}

# Install the AWS plugin.
provider "aws" {
  version = "1.26.0"
  region  = "us-east-1"
}

# Store the newrelic api key in S3.
data "aws_s3_bucket_object" "newrelic_api_key" {
  bucket = "some-bucket"
  key    = "a-key/terraform/provider_newrelic_api_key.txt"
}

# Install and configure the newrelic plugin.
provider "newrelic" {
  api_key = "${data.aws_s3_bucket_object.newrelic_api_key.body}"
  version = "~> 1.0.1"
}
