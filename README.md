<p align="center">
  <a href="https://jamfox.dev">
    <img alt="JF" src="https://raw.githubusercontent.com/JamFox/JamFox/main/images/icon.png" width="60" />
  </a>
</p>
<h1 align="center">
JamLab Terraform Provisioning
</h1>

Terraform configurations for provisioning homelab VMs.

## Usage

### Bootstrap

First you need to set up API access to Proxmox. Follow the [Telmate Proxmox Terraform Provider Docs](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/index.md).

The Proxmox API connection parameters need to be set as Terraform variables either using:

- a `.tfvars` file
- inline `-vars`
- environment variables
- updating the defaults in `variables.tf`

### Initializing and verifying configuration

Initialize the configuration directory to download and install the providers defined in the configuration:

```bash
terraform init
```

Format your configurations. Terraform will print out the names of the files it modified, if any:

```bash
terraform fmt
```

Make sure your configuration is syntactically valid and internally consistent

```bash
terraform validate
```

### Provisioning

Execute a dry run to verify configuration and see what would be done before executing apply:

```bash
terraform plan
```

Apply the plan and provision infrastructure as declared in configurations:

```bash
terraform apply
```

Unprovision infrastructure as declared in configurations:

```bash
terraform destroy
```

Using `-compact-warnings` flag will compact output, but still outputs errors in full.

#### Targeting specific resources

Any resources defined in `main.tf` can be targeted by using `-target="<RESOURCE>.<RESOURCE NAME>"`.

For example, target `base-infra` module:

```bash
terraform apply -target=module.base-infra
```

## Structure

```
main.tf                      # Main file used by Terraform commands
variables.tf                 # Global variables

modules/                     # Reusable modules
    pve-vm/                  # Proxmox VE VM provisioning template module

envs/                        # Environments dir
    prod/                    # Production infra definitions
        base-infra/          # Base infrastructure needed for services
            vars.tf          # Input variables
            outputs.tf       # Output variables
            main.tf          # Resources to be provisioned using modules
        service-infra/       # Services infrastructure
    dev/                     # Development infra definitions
       dev-vm/               # Development VM
```

