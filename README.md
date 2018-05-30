
# Usage

Individual directories contains example terraform specified infrastructures.
Copy whole directory to new name and customize. Use instructions in README.md

# Install Terraform

https://www.terraform.io/downloads.html

## With Habitat.sh

https://www.habitat.sh/docs/install-habitat/

      # optional
      hab studio enter

      hab install core/terraform
      hab install core/cacerts
      hab pkg binlink core/terraform


# Update 3rd party terraform plans

The script `Syncfile` contains instructions to fetch 3rd party terraform plans to `upstream` branch
and make them available in this repo for customization.

