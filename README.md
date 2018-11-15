# Terraform

##   T O C

1. What is Terraform ? ? ?
2. Creating resources
3. Inspecting Terraform state
4. Modifying + tainting resources
5. Shared State
6. Case study: Newrelic + Pagerduty setup
a. Modules, Multiple providers, Best practices
7. Postmortem: Deposed Resources

---

##  Terraform: An Intro

> HashiCorp Terraform enables you to safely and predictably create, change, and improve infrastructure. 
> 
> It is an open source tool that **codifies APIs into declarative configuration files**
> 
> that can be shared amongst team members, treated as code, edited, reviewed, and versioned.

### Infrastructure-as-Code: Benefits

1. Versioned
2. Audited
3. Reproducible
4. Predictable action times (automated replacement and recovery)

### Terraform: Benefits

1. Unified language (HCL) and API
2. Define important details, hide the other stuff (Declarative config formats)
  
### 12 Factor App Design

Andrew Wiggins, [https://12factor.net/](https://12factor.net/)

1. Minimize the complexity of defining infra + making changes
   1. Minimize time and cost for new developers to understand infrastructure and historical context

2. Unify configuration and deployment of services
   1. Scale and integrate services without significant changes to tooling, architecture, or development practices

3. Reduce the risk of making changes
   1. Minimize divergence between development and production, enabling continuous deployment.

---

##  Working With Resources

### Hashicorp Configuration Language (HCL)

- primitive, human-friendly syntax
- has basic obj constructs (bool, int, string, array, hash object)

```
 😭 😭  😭  😭  😭  😭  😭 😭   😭   😭   😭 
 😭    you're basically writing JSON   😭
 😭😭😭 😭😭 😭 😭😭   😭   😭   😭     😭 
```

```tf
resource "aws_vpc" "workshop_vpc" {
  cidr_block = "10.0.241.0/24"

  tags {
    source = "Terraform Knowledge Share"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = "${aws_vpc.workshop_vpc.id}"
  availability_zone = "us-east-1a"
  cidr_block = "10.0.241.0/26"

  tags {
    source = "Terraform Knowledge Share"
  }
}
```

### Terraform < 0.12

- no for loops;
- limited if/else support
- limited type support (relies on strings, auto-type conversions);
  - `ami_id = "${var.ami_id}"` instead of `ami_id = var.ami_id`

  https://www.hashicorp.com/blog/terraform-0-1-2-preview

Also: no debugging support (not even printf)

### Modification; Variables; Outputs

```tf
# Previously-made resources
#
data "aws_vpc" "workshop_vpc" {
  tags {
    source = "Terraform Knowledge Share"
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
       source = "Terraform Knowledge Share"
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
```

### Modules

```tf
module "chapter_4e_aws_instance" {
  ami_id = "ami-e3063199"
}

resource "aws_instance" "bastion" {
  ami_id = "ami-e3063199"
  associate_public_ip_address = true
  instance_type = "t2.micro"
  tags {
    source = "Terraform Knowledge Share"
  }

  subnet_id = "${module.chapter_4e_aws_instance.really_important_subnet_id}"
  key_name = "${module.chapter_4e_aws_instance.really_important_key_name}"
}
```

### Shared State

```tf
module "chapter_4e_aws_instance" {
  ami_id = "ami-e3063199"
}

 provider "aws" {
   version = "1.13.0"
   region = "us-east-1"
 }

 terraform {
   backend "s3" {
     bucket         = "kevin-tf-knowledge-share-test"
     key            = "terraform-knowledge-share/terraform/terraform.tfstate"
     region         = "us-east-1"
     dynamodb_table = "tf_lock"
   }
 }
```

---

## Case Study: New Relic and Pagerduty

### Main file

```tf
# Define the storage backend for the state file.
terraform {
  backend "s3" {
    bucket         = "some-bucket"
    key            = "terraform-knowledge-share/terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf_lock"
  }

  required_version = "~> 0.10.8"
}

# Configure the AWS plugin.
provider "aws" {
  version = "1.26.0"
  region  = "us-east-1"
}

# Configure the newrelic plugin.
#
# Store the newrelic api key in S3.
data "aws_s3_bucket_object" "newrelic_api_key" {
  bucket = "some-bucket"
  key    = "terraform-knowledge-share/terraform/provider_newrelic_api_key.txt"
}

provider "newrelic" {
  api_key = "${data.aws_s3_bucket_object.newrelic_api_key.body}"
  version = "~> 1.0.1"
}
```

### New Relic Alerts

```tf
# terraform newrelic docs: https://www.terraform.io/docs/providers/newrelic/index.html
#
# Set up some alerts using modules.
data "newrelic_application" "dev" {
  name = "Terraform Knowledge Share - dev"
}

resource "newrelic_alert_policy" "dev" {
  name = "Terraform Knowledge Share - test dev alert policy"
}

locals {
  where_dev_host          = "(`hostname` LIKE '%tf-knowledge-share-test-app-dev%')"
  where_dev_host_and_node = "${local.where_dev_host} AND `commandName` = 'node'"
}

module "newrelic_alerts_dev_infra" {
  source         = "git@github.com:CMSgov/tf-newrelic//alerts/infra_base?ref=v1.0.0"
  policy_id      = "${newrelic_alert_policy.dev.id}"
  where          = "${local.where_dev_host}"
  high_ram_name  = "High Ram Usage (node)"
  high_ram_where = "${local.where_dev_host_and_node}"
}

module "newrelic_alerts_dev_apm_web" {
  source         = "git@github.com:CMSgov/tf-newrelic//alerts/apm_web_base?ref=v1.0.0"
  policy_id       = "${newrelic_alert_policy.dev.id}"
  newrelic_app_id = "${data.newrelic_application.dev.id}"
}
```

### Pagerduty Integration

```tf
# terraform pagerduty docs: https://www.terraform.io/docs/providers/pagerduty/index.html

# Store the pagerduty-newrelic service keys in S3.
# When setting this up for the first time, you must ensure that the key is encrypted.
#
data "aws_s3_bucket_object" "pagerduty_low_priority_newrelic_service_key" {
  bucket = "some-bucket"
  key    = "terraform-knowledge-share/terraform/pagerduty_low_priority_newrelic_service_key.txt"
}

resource "newrelic_alert_channel" "pagerduty_low_priority" {
  name = "Terraform Knowledge Share - Pagerduty Alert Channel Low Priority"
  type = "pagerduty"

  configuration = {
    service_key = "${data.aws_s3_bucket_object.pagerduty_low_priority_newrelic_service_key.body}"
  }
}

# Link alert policies to low-priority channel.
#
resource "newrelic_alert_policy_channel" "dev_pagerduty_low_priority" {
  policy_id  = "${newrelic_alert_policy.dev.id}"
  channel_id = "${newrelic_alert_channel.pagerduty_low_priority.id}"
}
```

---

## Postmortem: Deposed Resources and Duplicate ASG Names

A resource is deposed when it is created by terraform, but fails to instantiate correctly.
These resources are tracked in the terraform state, and will be deleted in the next terraform apply.

```
                  _____                _______________
Original State   |ASG A|-============-|Launch Config A|
                 |_____|              |_______________| (deleted)
                    |  |                      |
                    |  |__                    |
                    v     |                   v
                   _____  |             _______________
 Apply 1          |ASG B|-============-|Launch Config B|
        (deposed) |_____| |            |_______________|
                      ____|               //
                     |                   //
                     v   _______________//
                   _____//
 Apply 2          |ASG B|
                  |_____|
```

---

##  Resources

1. https://github.com/18F/cloud-native-aws-terraform-workshop/
2. https://charity.wtf/2016/02/23/two-weeks-with-terraform/
3. https://github.com/ozbillwang/terraform-best-practices
