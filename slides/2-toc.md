                          # # # # # # #
                          #   T O C   #
                          # # # # # # #

                          1. What is Terraform ? ? ?
                          2. Creating AWS resources in terraform
                             a. Resource definitions
                             b. Dependency Links
                             c. CLI: plan / apply
                          3. Terraform state (viewing tfstate, CLI queries)
                          4. Terraform CLI: Modifying resources
                             a. Variables
                             b. detecting discrepencies between config and aws (t plan -- running t state update)
                                a. maybe add in a manual change from the aws console to show how it works better
                             c. changesets (modifying resources vs. create-and-destroy) (t plan -- viewing output)
                          5. Terraform CLI: Tainting resources
                          6. Case study: Newrelic + Pagerduty setup
                             a. Modules, Data resources
                          7. Failure Modes 1: Poisoned Locks
                             b. Lockfile
                             c. Deleting Lockfile
                          8. Failure Modes 2: Deposed Resources
