                          # # # # # # # # # # # ##
                          #  Defining Resources  #
                          # # # # # # # # # # # ##

resource "aws_vpc" "workshop_vpc" {
  cidr_block = "10.0.241.0/24"

  tags {
    source = "QPP Knowledge Share"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = "${aws_vpc.workshop_vpc.id}"
  availability_zone = "us-east-1a"
  cidr_block = "10.0.241.0/26"

  tags {
    source = "QPP Knowledge Share"
  }
}
