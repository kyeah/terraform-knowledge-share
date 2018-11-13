                          # # # # # # # # # # # ##
                          #  Defining Resources  #
                          # # # # # # # # # # # ##

# Terraform < 0.12

    - no for loops;
    - limited if/else support
    - limited type support (relies on strings, auto-type conversions);
        : ami_id = "${var.ami_id}" instead of ami_id = var.ami_id

    https://www.hashicorp.com/blog/terraform-0-1-2-preview

    - no debugging support (not even printf)
