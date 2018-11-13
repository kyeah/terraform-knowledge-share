                          # # # # # # # # # # # ##
                          #  Defining Resources  #
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
