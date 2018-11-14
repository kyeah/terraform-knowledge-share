                          # # # # # # # # # # # ##
                          #     Shared State     #
                          # # # # # # # # # # # ##

provider "aws" {
  version = "1.13.0"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "some-bucket"
    key            = "app-dev/terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf_lock"
  }
}

# Previously-made resources
#
# data "aws_vpc" "workshop_vpc" {
#   cidr_block = "10.0.241.0/24"

#   tags {
#     source = "QPP Knowledge Share"
#   }
# }

# data "aws_subnet" "public_subnet_1" {
#   vpc_id = "${aws_vpc.workshop_vpc.id}"
#   availability_zone = "us-east-1a"
#   cidr_block = "10.0.241.0/26"

#   tags {
#     source = "QPP Knowledge Share"
#   }
# }

# data "aws_instance" "bastion" {
#   ami = "new-ami-id"
#   subnet_id = "${aws_subnet.public_subnet_1.id}"
#   associate_public_ip_address = true
#   key_name = "[key name]"
#   instance_type = "t2.micro"
# }
