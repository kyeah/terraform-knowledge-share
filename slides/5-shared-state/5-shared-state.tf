                          # # # # # # # # # # # ##
                          #     Shared State     #
                          # # # # # # # # # # # ##

# Previously-made resources
#
data "aws_vpc" "workshop_vpc" {
  tags {
    source = "QPP Knowledge Share"
  }
}

data "aws_subnet" "public_subnet_1" {
  vpc_id = "${data.aws_vpc.workshop_vpc.id}"
}

data "aws_instance" "bastion" {
  instance_tags = {
    source = "QPP Knowledge Share"
  }
}

# provider "aws" {
#   version = "1.13.0"
#   region = "us-east-1"
# }

# terraform {
#   backend "s3" {
#     bucket         = "some-bucket"
#     key            = "app-dev/terraform/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "tf_lock"
#   }
# }
