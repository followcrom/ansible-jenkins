# Ansible

## Install Ansible

```bash
sudo apt-get install software-properties-common

sudo apt-add-repository ppa:ansible/ansible

sudo apt update -y

sudo apt install ansible -ansible -y
```

# Ansible add agent

Add agent's IP and ssh key to /etc/ansible/hosts. For example:

```bash
# Add agent's IP and ssh key to /etc/ansible/hosts
ec2-instance ansible_host=public.ip.address.of.agent ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/tech257.pem
```

Ansible is Agentless, so no need to install anything on the agent.

## adhoc commands


sudo ansible all -m ping
This command will ping all the hosts in the inventory file.

sudo ansible web -a "uname -a"

This command will run the uname -a command on the web group of hosts.


sudo ansible all -a "date"
This command will run the date command on all the hosts in the inventory file.

sudo ansible all -a "free"
This command will run the free command on all the hosts in the inventory file.

sudo ansible all -a "ls -a"
This command will run the ls -a command on all the hosts in the inventory file.

super verbose:
sudo ansible all -m ping -vvvv
This command will ping all the hosts in the inventory file and display the output in super verbose mode.

sudo sudo ansible web -m ansible.builtin.copy -a "src=tech257.pem dest=/home/ubuntu/.ssh/tech257.pem"
This command will copy the tech257.pem file from the local machine to the /home/ubuntu/.ssh/ directory on the web group of hosts.

sudo ansible web -m ansible.builtin.shell -a "ls -a"
This command will run the ls -a command on the web group of hosts using the shell module.