THISDIR := $(notdir $(CURDIR))
PROJECT := $(THISDIR)
# system connection, in case LIBVIRT_DEFAULT_URI env var is not defined
LIBVIRT_URI := qemu:///system
TF := terraform
TF_ARGS := ""
# ARGS
VM := "cmp1-kvm"

apply: init libvirt-prereq
	$(TF) apply -auto-approve $(TF_ARGS)

init:
	$(TF) init

destroy:
	$(TF) destroy -auto-approve
	#./clean-known-hosts.sh
	rm terraform.tfstate*

destroyvm:
	virsh destroy $(VM) || true
	virsh undefine $(VM)

## create public/private keypair for ssh
create-keypair:
	# skips if file already exists
	[ -f id_ed25519 ] || ssh-keygen -t ed25519 -C $(PROJECT) -N "" -q

refresh:
	$(TF) refresh
	$(TF) output

libvirt-prereq:
	@echo Making sure libvirt default disk pool and network exist
	virsh --connect $(LIBVIRT_URI) pool-info default
	virsh --connect $(LIBVIRT_URI) net-info default

	@echo Making sure virtual bridge 'br0' exists on host
	ip a show br0
	@echo Making sure libvirt 'host-network' exists that uses 'br0' host bridge
	virsh --connect $(LIBVIRT_URI) net-info host-network

libvirt-pool:
	$(eval POOLDIR=$(shell virsh --connect ${LIBVIRT_URI} pool-dumpxml default | grep -E "<path>.*</path>" | grep -Po "(?<=\>)[^<]+"))

## validate syntax of cloud_init
validate-cloud-config:
	cloud-init devel schema --config-file cloud_init.cfg

virsh-create-snapshot:
	virsh snapshot-create-as $(VM) --name makefile-$(VM) --disk-only --diskspec vda,snapshot=internal --diskspec hdd,snapshot=no

virsh-snapshot-delete:
	virsh destroy $(VM)
	sleep 5
	virsh snapshot-delete $(VM) makefile-$(VM)
