# # # # # # # # # # ##
# Terraform Workshop #
# # # # # # # # # # ##

Extremely underprepared 45min deep-dive on all the useful Terraform things for the well-informed app developer / on-call human

I should have used a presentation framework

🚧 WIP 🚧

1. What is Terraform ? ? ?
2. Creating AWS resources in terraform
   1. Resource definitions
   2. Dependency Links
   3. CLI: plan / apply (reading plan output pt 1)
3. Terraform state (viewing tfstate, CLI queries)
4. Terraform CLI: Modifying resources
   1. Variables
   2. Detecting discrepencies between config and aws (how state is updated before commands)
      1. maybe add in a manual change from the aws console to show how it works better
   3. changesets (modifying resources vs. create-and-destroy) (how to read plan output pt 2)
   4. Terraform CLI: Tainting resources
5. Case study: Newrelic + Pagerduty setup
   1. Modules, Data resources
6. Failure Modes 1: Poisoned Locks
   1. Shared state
   2. Deleting Lockfile
7. Failure Modes 2: Deposed Resources
   1. DIAGRAM TIME

---------------

# # # # # # # #
#  Terraform  #
# # # # # # # #

> HashiCorp Terraform enables you to safely and predictably create, change, and improve infrastructure. 
> 
> It is an open source tool that **codifies APIs into declarative configuration files**
> 
> that can be shared amongst team members, treated as code, edited, reviewed, and versioned.

## Infrastructure-as-Code: Benefits

    Versioned
    Audited
    Reproducible
    Predictable action times (automated replacement and recovery)

## Terraform: Benefits

    Unified language (HCL) and API
    Define important details, hide the other stuff (Declarative config formats)


    => Minimize the complexity of defining infra + making changes
       Minimize time and cost for new developers to understand infrastructure and historical context

    => Unify configuration and deployment of services
       Scale and integrate services without significant changes to tooling, architecture, or development practices

    => Reduce the risk of making changes
       Minimize divergence between development and production, enabling continuous deployment.

       — Andrew Wiggins, https://12factor.net/

------------------------

# # # # # # # # # # # ##
#  Defining Resources  #
# # # # # # # # # # # ##

## Hashicorp Configuration Language (HCL)

    - primitive, human-friendly syntax
    - has basic obj constructs (bool, int, string, array, hash object)

```terraform
resource "aws_vpc" "workshop_vpc" {
    cidr_block = "10.0.5.0/24"
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id = "${aws_vpc.workshop_vpc.id}"
    availability_zone = "us-east-1a"
    cidr_block = "10.0.5.0/26"
}

😭 😭  😭  😭  😭  😭  😭 😭   😭   😭   😭 
😭    you're basically writing JSON   😭
😭😭😭 😭😭 😭 😭😭   😭   😭   😭     😭 
```

## Terraform < 0.12

- no for loops;
- limited if/else support
- limited type support (relies on strings, auto-type conversions);
  - `ami_id = "${var.ami_id}"` instead of `ami_id = var.ami_id`
    https://www.hashicorp.com/blog/terraform-0-1-2-preview

Also: debugging sucks (don't even have good console logging options)

## Variables

Let's add a bastion instance. Also variables. Maybe an output.

```terraform
resource "aws_vpc" "workshop_vpc" {
    cidr_block = "10.0.5.0/24"
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id = "${aws_vpc.workshop_vpc.id}"
    availability_zone = "us-east-1a"
    cidr_block = "10.0.5.0/26"
}

resource "aws_instance" "bastion" {
    ami = "${var.ami_id}"
    subnet_id = "${aws_subnet.public_subnet_1.id}"
    associate_public_ip_address = true
    key_name = "[key name]"
    instance_type = "t2.micro"
}
```

---------------

# # # # # # # ##
# Shared State #
# # # # # # # ##

## .....Shared state

yeah that's right i skipped straight to the shared state section

```
provider "aws" {
  version = "1.13.0"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "some-bucket-idk"
    key            = "app-dev/terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf_lock"
  }
}
```

# # # # # # # #
#  Resources  #
# # # # # # # #

1. [https://github.com/18F/cloud-native-aws-terraform-workshop/](https://github.com/18F/cloud-native-aws-terraform-workshop/)
2. [https://charity.wtf/tag/terraform/](https://github.com/18F/cloud-native-aws-terraform-workshop/)
