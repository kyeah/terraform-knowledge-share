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

# ami-c481fad3
# resource "aws_instance" "bastion" {
#     ami = "${var.ami_id}"
#     subnet_id = "${aws_subnet.public_subnet_1.id}"
#     associate_public_ip_address = true
#     key_name = "[key name]"
#     instance_type = "t2.micro"
# }
