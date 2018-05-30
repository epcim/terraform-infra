

## Tools required

The tools and setup is opinionated and highly optional ;)

### ubuntu

    apt-get install -y direnv python-pipenv python-pip

## Setup OpenStack environment

Download your keystonerc/openrc and store as .envrc in your working directory

    #V2
    https://lab.youropenstack.com/project/api_access/openrcv2/
    #V3
    https://lab.youropenstack.com/project/api_access/openrc/

Or manually::


    OS_USERNAME=XYZ 
    OS_PASSWORD=XYZ 
    cat <<-EOF >> ./.envrc
    	# rc
    	export OS_AUTH_URL=https://lab.mirantis.com:5000/v3
    	export OS_PROJECT_ID=${OS_PROJECT_ID:-52536594831e4071b3e47fc2732235c9}
    	export OS_PROJECT_NAME="${OS_PROJECT:-mirantis-services-eu}"
    	export OS_USER_DOMAIN_NAME="default"
    	export OS_USERNAME=${OS_USERNAME}
    	export OS_PASSWORD=${OS_PASSWORD}
    	export OS_REGION_NAME="RegionOne"
    	export OS_INTERFACE=public
    	export OS_IDENTITY_API_VERSION=3
    	# use virtualenv
    	pipenv --py && pipenv shell
    EOF

Install openstack client libs in isolated environment:

    # first time only 
    pipenv --three install python-openstackclient
    direnv allow .

    # later
    pipenv shell
    openstack project list
    ...
    openstack-inventory --list > inventory.json

    # inspect with
    jq -r  \
         '.[]|"\(.location.region_name)@\(.location.project.name)@\(.key_name)@\(.properties."OS-EXT-SRV-ATTR:host")/\(.properties."OS-EXT-SRV-ATTR:instance_name")/\(.name|split(".")[0]) (\(.properties."OS-EXT-STS:vm_state"))"' \
         inventory.json |column -t -s '@' | sort -k3


## Configure Terraform provider

Get IDs and Names of openstack objects

    openstack image list
    openstack flavor list
    openstack network list
    openstack network list --external # the gateway
    openstack availability zone list
    openstack security group list
    ...

And configure `variables.tf` and `provisioner.tf` as required.

## Customize

The folder contains `main.tf` that creates base infrastructure (netwroks, routers, ssh keys, ...) for given deployment configured in `deploy.tf` (instances, floating ip).
If `outputs.tf` exist, in this file you may control what Terraform will hold as a record after the states are applied.

I am very fresh to terraform, but basically to share `main.tf` and `deploy.tf` with multiple instances I use `${var.tag_label}`, `${tag_env}`
and `${var.tag_cluster}` to set objects "tagged" with unique name per my deployment.

## Deployment

Basic terraform commands:

    # first time (to download used plugins, etc..)
    terraform init

    # to review
    terraform plan

    # to execute (note, some are optional)
    terraform apply \
      -var "openstack_auth_url=$OS_AUTH_URL"\
      -var "openstack_username=$OS_USERNAME"\
      -var "openstack_password=$OS_PASSWORD"\
      -var "openstack_project=$OS_PROJECT_NAME"\
      -var "openstack_domain=$OS_USER_DOMAIN_NAME"\
      -var "external_gateway=$(openstack network list --external -f value -c ID)" \
      -var "pool=public"

    terraform outputs

    # to decommision
    terraform destroy

Note you may want to run content in `main.tf` independently, as these you might want to share these or keep them for next
execution.


