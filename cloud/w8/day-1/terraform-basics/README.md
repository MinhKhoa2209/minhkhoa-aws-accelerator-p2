# Terraform Basics Sandbox


## Contents

- `versions.tf`: version constraint
- `variables.tf`: input variables and validation
- `locals.tf`: maps/lists/objects and `for` expressions
- `outputs.tf`: outputs to observe how Terraform evaluates expressions
- `terraform.tfvars.example`: example variable overrides

## Suggested Commands

```powershell
terraform fmt -recursive
terraform validate
terraform console
```

After entering `terraform console`, you can try:

```hcl
local.standard_tags
local.w8_paths
local.learning_summary
```
