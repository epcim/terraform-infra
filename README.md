
# Usage

Individual directories contains example terraform specified infrastructures.
Copy whole directory to new name and customize. Use instructions in README.md

# Install Terraform

https://www.terraform.io/downloads.html

    LATEST_TERRAFORM_VERISON=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')
    curl "https://releases.hashicorp.com/terraform/${LATEST_TERRAFORM_VERISON}/terraform_${LATEST_TERRAFORM_VERISON}_linux_amd64.zip" --output /tmp/terraform_linux_amd64.zip
    sudo unzip /tmp/terraform_linux_amd64.zip -d /usr/local/bin/

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


# Sources

Docs:
- https://www.terraform.io/docs/index.html
- https://www.hashicorp.com/blog/terraform-0-1-2-preview

Modules:
- https://registry.terraform.io/
- https://github.com/epcim/terraform-modules
