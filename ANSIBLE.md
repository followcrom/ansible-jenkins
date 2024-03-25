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

ping all the hosts in the hosts file:

`sudo ansible all -m ping`

ping all the hosts in the inventory file and display the output in super verbose mode.

`sudo ansible all -m ping -vvvv`

run the uname -a command (this will display the system information) on all the hosts in the inventory file:

`sudo ansible web -a "uname -a"`

run the date command on all the hosts in the inventory file:

`sudo ansible all -a "date"`

run the free command on all the hosts in the inventory file:

`sudo ansible all -a "free"`

run the ls -a command on all the hosts in the inventory file:

`sudo ansible all -a "ls -a"`

copy the tech257.pem file from the local machine to the /home/ubuntu/.ssh/ directory on the web group of hosts:

`sudo sudo ansible web -m ansible.builtin.copy -a "src=tech257.pem dest=/home/ubuntu/.ssh/tech257.pem"`

check status of nginx in the web group of hosts:

```bash
sudo ansible web -a "systemctl status nginx"
```

## Ansible Playbooks

Create a playbook file:

```bash
sudo nano playbook.yml
```

Add content to the playbook.yml file (e.g. install Nginx):

```yaml
---
- name: Install Nginx
  hosts: web
  gather_facts: yes
  become: true
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
```

To test the syntax of the playbook:

```bash
sudo ansible-playbook playbook.yml --syntax-check
```

Run the playbook:

```bash
sudo ansible-playbook playbook.yml
```

## Ansible Playbook to set up and start _sta_ on agent

```yaml
---

- name: Install dependencies and run the application in the background
  hosts: web
  gather_facts: yes
  become: true

  tasks:
    # Install Node.js
    - name: Install Node.js
      apt:
        name: nodejs
        state: present
        update_cache: yes

    # Install npm to manage Node.js packages
    - name: Install npm
      apt:
        name: npm
        state: present

    # Install Git
    - name: Install Git
      apt:
        name: git
        state: present

    # Clone the app from GitHub
    - name: Clone the app from GitHub
      git:
        repo: https://github.com/followcrom/sta-cicd.git
        dest: /home/ubuntu/repo
        version: main
        clone: yes
        update: yes

    # Install app dependencies using npm
    - name: Install app dependencies with npm
      command: npm install
      args:
        chdir: /home/ubuntu/repo/app

    # Start the application in the background using nohup
    - name: Start the application in the background
      ansible.builtin.shell: nohup npm start > /dev/null 2>&1 &
      args:
        chdir: /home/ubuntu/repo/app
      async: 10
      poll: 0
```