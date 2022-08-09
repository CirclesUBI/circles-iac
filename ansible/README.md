# Provisioning RPC node and Graph Node

## Requirements
- [Ansible](https://www.ansible.com/)
- [Vagrant](https://www.vagrantup.com/downloads)
- A  virtualization env such as:  VirtualBox, VMware Fusion, or Hyper-V.
- Server with Debian 11

## Description
Ansible manages the installation of any software component using different [roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#roles).

### group_vars
It contains all the variables used in every role. Please change accordingly to install a sokol or a xdai node. 
It also allows to add users for the rpc nethermind node under `allowed_users`.
:warning: 

### roles
- **basic-setup**: installs required packages and enable unattended security updates. 
- **nethermind**: installs a customised helm chart for nethermind node using the xdai network and adc hoc k8s resources required to secure the node. 
    - Version  [v1.12.7](https://github.com/NethermindEth/nethermind/releases/tag/1.12.7)
    - This node has security enabled and not everyone can connect to it. To be added please write to circlesubi@
- **graph-protocol**: installs a customised helm chart for graph-protocol.
### host.yaml
Target machine where `prd` provisioning will take place. 

### playbook.yaml
Roles and configuration for provisioning 

### Vagrantfile
For local development with vagrant. Please go to `Running - against a virtual envinronment` for more details. 

## Running 

### Against a virtual envinroment 
Use the `Vagrantfile` provided. The basics commands are:
`vagrant up`: starts the virtual machine 
`vagrant provision`: installs playbook.yaml
`vagrant ssh`: ssh into the machine
`vagrant destroy`: destroys virtual

To know more please refer to [Vagrant CLI](https://www.vagrantup.com/docs/cli)

### Against a server 
Update in `hosts.yaml` the target box where the software will be installed. 

```ansible-playbook  playbook.yaml -i hosts.yaml -vvv```

## Adding new user to the RPC node 

- Locally create a new user  with htdigest: `htdigest -c httpd-pwd-file traefik NEW_USER`. It will prompt to add a password. Please make sure this is a strong password. 
- Encode the result in base64: `cat httpd-pwd-file |  base6` 
- The result add in `group_vars/all` under `allowed_users`