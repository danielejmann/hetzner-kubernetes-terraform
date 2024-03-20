#Hetzner-kubernetes-terraform

This repository contains a Terraform configuration which builds virtual machines on the Hetzner cloud. The configuration will build out the base infrastructure but does not build out Kubernetes on the virtual machines, I plan to create another repository which will do this.

The configuration of this repository has been designed to be fully customisable, and will (by default):

- Create a network 10.11.11.0/24
- Create a smaller subnet 10.11.11.0/29 which contains enough IP space for 6 hosts
- Create a 'spread' placement group to ensure the VMs are running on different hosts, or multiple sites (if applicable) for redundancy.
- Create 3 control plane nodes named k8s-master-\*. 3 nodes or more (odd number in total) is recommended for production to avoid split brain.
- Create 2 worker nodes named k8s-worker-\*
- Create a ansible user with sudo privileges and a SSH key using cloud-init

##Usage

There are a few steps you will need to perform prior to using this Terraform configuration.

- Create a SSH key pair and make note of the public key.
- Create a read & write API token within your Hetzner account under the relevant project.

Create a .tfvars file with the following contents:

```
hcloud_token = "<YourAPIToken>"
ansible_ssh_public_key = "<YourPublicKey>"
ansible_ssh_key_type = "<YourSSHKeyType>"
```

Run the following:

```
terraform init
```

```
terraform plan
```

```
terraform apply
```

##Variables

As mentioned prior, the build of the VMs are fully customisable therefore you can edit the default variables within the variables.tf file or use the following syntax.

```
terraform apply -var 'network_ip_range=10.11.11.0/24' -var 'cluster1_ip_range=10.11.11.0/29' -var 'location=fsn1' -var 'num_masters=3' -var 'num_workers=2' -var 'hcloud_token=YOUR_HETZNER_API_TOKEN' -var 'image=ubuntu-22.04' -var 'server_type_master=cx21' -var 'server_type_worker=cx31' -var 'ansible_ssh_public_key=YOUR_SSH_PUBLIC_KEY' -var 'ansible_ssh_key_type=YOUR_SSH_KEY_TYPE'
```
