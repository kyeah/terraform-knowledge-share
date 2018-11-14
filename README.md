<!--# # # # # # # # # # ##-->
#     Terraform Workshop
<!--# # # # # # # # # # ##-->

Extremely underprepared 45min deep-dive on all the useful Terraform things for the well-informed app developer / on-call human

I should have used a presentation framework

🚧 WIP 🚧

---

1. What is Terraform ? ? ?
2. Creating AWS resources in terraform
   1. Resource definitions
   2. Dependency Links
   3. CLI: plan / apply (reading plan output pt 1)
3. Inspecting Terraform state (viewing tfstate, CLI queries)
4. Modifying and tainting resources
   1. Variables, Data sources
   2. Detecting discrepencies between config and aws (how state is updated before commands)
      1. maybe add in a manual change from the aws console to show how it works better
   3. changesets (modifying resources vs. create-and-destroy) (how to read plan output pt 2)
5. Shared State
   1. Remote Backends
   2. Lockfiles
6. Case study: Newrelic + Pagerduty setup
   1. Modules, multiple providers, best practices
7. Postmortem: Deposed Resources
   1. DIAGRAM TIME

---

<!--# # # # # # # #-->
#     Terraform 
<!--# # # # # # # #-->

> HashiCorp Terraform enables you to safely and predictably create, change, and improve infrastructure. 
> 
> It is an open source tool that **codifies APIs into declarative configuration files**
> 
> that can be shared amongst team members, treated as code, edited, reviewed, and versioned.

---

## Infrastructure-as-Code: Benefits

- Versioned
- Audited
- Reproducible
- Automated (Predictable task times, less prone to error)

---

## Terraform: Benefits

- Unified language (HCL) and API
- Declarative format: Define important details, hide the cruft

---

1. **Minimize the complexity of defining infra + making changes**
   <br>
   Minimize time and cost for new developers to understand infrastructure and historical context
   
2. **Unify configuration and deployment of services**
   <br>
   Scale and integrate services without significant changes to tooling, architecture, or development practices

3. **Reduce the risk of making changes**
	<br>
	Minimize divergence between development and production, enabling continuous deployment.

    — Andrew Wiggins, https://12factor.net/

---

<!--# # # # # # # # # # # ##-->
#     Defining Resources
<!--# # # # # # # # # # # ##-->

## Hashicorp Configuration Language (HCL)

- primitive, human-friendly syntax
- has basic obj constructs (bool, int, string, array, hash object)

---

```terraform
resource "aws_vpc" "workshop_vpc" {
    cidr_block = "10.0.5.0/24"
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id = "${aws_vpc.workshop_vpc.id}"
    availability_zone = "us-east-1a"
    cidr_block = "10.0.5.0/26"
}
```

---

```
😭 😭  😭  😭  😭  😭  😭 😭   😭   😭   😭 
😭    you're basically writing JSON   😭
😭😭😭 😭😭 😭 😭😭   😭   😭   😭     😭 
```

---

## Terraform < 0.12

- no for loops;
- limited if/else support
- limited type support (relies on strings, auto-type conversions);
  - `ami_id = "${var.ami_id}"` instead of `ami_id = var.ami_id`
    https://www.hashicorp.com/blog/terraform-0-1-2-preview

Also: debugging sucks (don't even have good console logging options)

---

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

---

<!--# # # # # # # #-->
#    Case Study: New Relic and Pagerduty Setup
<!--# # # # # # # #-->

Using modules, relying on existing data resources

<!--# # # # # # # ##-->
#    Shared State
<!--# # # # # # # ##-->

## Remote backends

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

---

## tf_lock

## poisoned locks



---

<!--# # # # # # # #-->
#      Deposed Resources
<!--# # # # # # # #-->

d i a g r a m

---

<!--# # # # # # # #-->
#      Resources
<!--# # # # # # # #-->

1. [https://github.com/18F/cloud-native-aws-terraform-workshop/](https://github.com/18F/cloud-native-aws-terraform-workshop/)
