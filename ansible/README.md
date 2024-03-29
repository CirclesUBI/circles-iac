# Provisioning RPC node and Graph Node

## Requirements
- [Ansible](https://www.ansible.com/)
- [Vagrant](https://www.vagrantup.com/downloads)
- A virtualization env such as: VirtualBox, VMware Fusion, or Hyper-V.
- Server with Debian 11

## Description
Ansible manages the installation of any software component using different [roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#roles).

### `group_vars`
It contains all the variables used in every role.
It also allows to add users for the Nethermind rpc node under `allowed_users`.

### roles
- **basic-setup**: installs required packages and enable unattended security updates.
- **rpcnode**: installs a customised helm chart for nethermind node using the xdai network and adc hoc k8s resources required to secure the node + lighthouse CL.
    - Nethermind version  [v1.25.4](https://github.com/NethermindEth/nethermind/releases/tag/1.25.4)
    - Lighthouse version [v5.0.0](https://github.com/sigp/lighthouse/releases/tag/v5.0.0)
    - This node has security enabled and not everyone can connect to it. To be added please write to circlesubi@bitspossessed.org
- **graph-protocol**: installs a customised helm chart for graph-protocol version [v0.1.2](https://github.com/CirclesUBI/circles-helm/releases/tag/circles-graph-node-0.1.2)

### `host.yaml`
Target machine where `prd` provisioning will take place.

### `playbook.yaml`
Roles and configuration for provisioning.

### `Vagrantfile`
For local development with vagrant. Please go to `Running > Against a virtual envinronment` for more details.

## Running

### Against a virtual envinroment
Use the `Vagrantfile` provided. The basics commands are:
`vagrant up`: starts the virtual machine
`vagrant provision`: installs playbook.yaml
`vagrant ssh`: ssh into the machine
`vagrant destroy`: destroys virtual

To know more please refer to [Vagrant CLI](https://www.vagrantup.com/docs/cli).

⚠️ Prior to run against the development machine check that the envinroment variables in `group_vars/all.yml` are set.

### Against a server
Update in `hosts.yaml` the target box where the software will be installed.

```ansible-playbook  playbook.yaml -i hosts.yaml```

## Adding new user to the RPC node
- Locally create a new user with `htdigest`: `htdigest -c httpd-pwd-file traefik NEW_USER`. It will prompt to add a password. Please make sure this is a strong password.
- Encode the result in base64: `cat httpd-pwd-file |  base6`
- The result add in `group_vars/all` under `allowed_users`

### Kwnown problems
- In order to have running this setup in vagrant you would need a powerful PC (specs below) , as required to run Graph Node and an Ethereum Full Node. Otherwise the setup will be slow and eventually it can run out of memory. The recommendation is to carry on the installation in a different server than your own PC.


### Limitations

- This is a very customised installation, meaning that only installs an ethereum node for xdai but not for chiado. It installs graphnode for both chiado and xdai that can be seen in the networks values. The subgraph job are for start indexing are installed separately check under `circles-iac/helm/circles-subgraphs`

#### PC specs

CPU : 8 cores
Memory (Postgres): 30GB
RAM: minimum 16GB (depending on the blockchain used)
