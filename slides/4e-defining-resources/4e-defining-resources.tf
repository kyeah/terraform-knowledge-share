                          # # # # # # # # # # # ##
                          #  Defining Resources  #
                          # # # # # # # # # # # ##

data "aws_vpc" "workshop_vpc" {
  cidr_block = "10.0.241.0/24"

  tags {
    source = "QPP Knowledge Share"
  }
}

data "aws_subnet" "public_subnet_1" {
  vpc_id = "${aws_vpc.workshop_vpc.id}"
  availability_zone = "us-east-1a"
  cidr_block = "10.0.241.0/26"

  tags {
    source = "QPP Knowledge Share"
  }
}

# ami-c481fad3
# variable "ami_id" {
#     description = "Launch with this AMI id."
#     type        = "string"
#     default     = "ami-123"
# }
#
# resource "aws_instance" "bastion" {
#     ami = "${var.ami_id}"
#     subnet_id = "${aws_subnet.public_subnet_1.id}"
#     associate_public_ip_address = true
#     key_name = "[key name]"
#     instance_type = "t2.micro"
# }
