                          # # # # # # # # # # # ##
                          #  Defining Resources  #
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

variable "ami_id" {
    description = "Launch with this AMI id."
    type        = "string"
    default     = "ami-6871a115"
}

resource "aws_instance" "bastion" {
    ami = "${var.ami_id}"
    subnet_id = "${data.aws_subnet.public_subnet_1.id}"
    associate_public_ip_address = true
    key_name = "kevin-tf-knowledge-share-test"
    instance_type = "t2.micro"
    tags = {
      source = "QPP Knowledge Share"
    }
}

output "really_important_subnet" {
  description = "subnet you should use everywhere"
  value = "${data.aws_subnet.public_subnet_1.vpc_id}"
}

output "really_important_key_name" {
  description = "the extremely secure key that you should have"
  value = "${aws_instance.bastion.key_name}"
}



# note for kevin don't look
# ami-e3063199
# terraform-docs md . > README.md
