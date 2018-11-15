                          # # # # # # # # # # # ##
                          #     Shared State     #
                          # # # # # # # # # # # ##

module "chapter_4e_aws_instance" {
  ami_id = "ami-e3063199"
}

# provider "aws" {
#   version = "1.13.0"
#   region = "us-east-1"
# }

# terraform {
#   backend "s3" {
#     TODO
#     bucket         = "kevin-qpp-knowledge-share-test"
#     key            = "app-dev/terraform/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "tf_lock"
#   }
# }
