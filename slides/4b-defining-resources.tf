                          # # # # # # # # # # # ##
                          #  Defining Resources  #
                          # # # # # # # # # # # ##

resource "aws_vpc" "workshop_vpc" {
    cidr_block = "10.0.5.0/24"
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id = "${aws_vpc.workshop_vpc.id}"
    availability_zone = "us-east-1a"
    cidr_block = "10.0.5.0/26"
}
