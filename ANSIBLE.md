# Ansible

## Install Ansible

Install Ansible on the controller instance. Ansible is Agentless, so no need to install anything on the agent.

```bash
sudo apt update && sudo apt upgrade -y

sudo apt-get install software-properties-common

sudo apt-add-repository ppa:ansible/ansible

sudo apt update -y

sudo apt install ansible -y
```

## Add ssh key to agent

```bash
eval `ssh-agent -s`
ssh-add ~/.ssh/tech257.pem
```

`sudo chmod 400 tech257.pem`

# Ansible add agent

`ansible --version`

`cd /etc/ansible`

Add agent's IP and ssh key to /etc/ansible/hosts. For example:

```bash
# Add agent's IP and ssh key to /etc/ansible/hosts
ec2-instance ansible_host=public.ip.address.of.agent ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/tech257.pem
```

To add multiple agents, add them to the hosts file in the same format as above.

```bash
[web]
ec2-app ansible_host=54.170.203.240 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/tech257.pem

[db]
ed2-db ansible_host=3.253.255.176 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/tech257.pem
```

[web] is the group name. You can have multiple groups in the hosts file. Give each group a name in square brackets and each individual agent in the group a name.

## adhoc commands

ping all the hosts in the hosts file:

`sudo ansible all -m ping`

ping all the hosts in the inventory file and display the output in super verbose mode.

`sudo ansible all -m ping -vvvv`

run the uname -a command (this will display the system information) on all the hosts in the inventory file:

`sudo ansible all -a "uname -a"`

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

ssh into the agent from the controller:

ssh -i ~/.ssh/tech257.pem ubuntu@ec2-34-240-72-134.eu-west-1.compute.amazonaws.com


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

## Ansible playback to install mongodb on DB instance

```yaml

---

- name: Install MongoDB
  hosts: db
  gather_facts: yes
  become: true
  tasks:
    - name: Install MongoDB
      apt:
        name: mongodb
        state: present

```


```bash
sudo ansible db -a "systemctl status mongodb"
```

## Ansible Playbook v3

```yaml

---

- name: Configure MongoDB and App Servers
  hosts: all
  gather_facts: yes
  become: true

  tasks:
    - name: Update mongod.conf to listen on all interfaces
      block:
        - name: Change bindIp in mongodb.conf
          lineinfile:
            path: /etc/mongodb.conf
            regexp: '^(\s*)bindIp: 127\.0\.0\.1(\s*)$'
            line: '\1bindIp: 0.0.0.0\2'
            backrefs: yes

        - name: Restart MongoDB
          systemd:
            name: mongodb
            state: restarted
            daemon_reload: yes

        - name: Wait for MongoDB to restart
          wait_for:
            port: 27017
            timeout: 15
      when: "'db' in group_names"

    - name: Update Nginx configuration for proxy_pass
      ansible.builtin.lineinfile:
        path: /etc/nginx/sites-available/default
        regexp: '^\s*try_files \$uri \$uri/ =404;$'
        line: '        proxy_pass http://localhost:3000/;'
        backrefs: yes
      notify: restart nginx
      when: "'web' in group_names"

    - name: Stop the app if it is running
      ansible.builtin.shell: pkill node || true
      when: "'web' in group_names"

    - name: Set persistent environment variable DB_HOST and run npm install
      block:
        - name: Set DB_HOST environment variable
          lineinfile:
            path: /home/ubuntu/repo/app/.env
            line: 'DB_HOST=mongodb://34.248.5.252:27017/posts'
            create: yes

        - name: Run npm install
          ansible.builtin.shell: npm install
          args:
            chdir: /home/ubuntu/repo/app
      when: "'web' in group_names"

    - name: Restart the app
      block:
        - name: Set DB_HOST environment variable and run seed.js script
          ansible.builtin.shell: |
            export DB_HOST='mongodb://34.248.5.252:27017/posts' && node seed.js
          args:
            chdir: /home/ubuntu/repo/app/seeds
          when: "'web' in group_names"

        - name: Start the application with DB_HOST environment variable
          ansible.builtin.shell: |
            export DB_HOST='mongodb://34.248.5.252:27017/posts' && nohup npm start > /dev/null 2>&1 &
          args:
            chdir: /home/ubuntu/repo/app
          async: 10
          poll: 0
      when: "'web' in group_names"

  handlers:
    - name: restart nginx
      ansible.builtin.service:
        name: nginx
        state: restarted


```

## Ansible Playbook v4 (complete)

# playbook.yml

```yaml
---

- name: Install MongoDB
  import_playbook: install-mongodb.yml

- name: Configure MongoDB Server
  import_playbook: config-mongodb.yml

- name: Install Nginx
  import_playbook: install-nginx.yml

- name: Install Node.js and App Dependencies
  import_playbook: install-nodejs-run.yml

```

sudo ansible-playbook playbook.yml --syntax-check

## Ansible imported playbooks

```yaml
# install-mongodb.yml
---
- name: Install and Configure MongoDB
  hosts: db
  gather_facts: yes
  become: true

  tasks:
    - name: Install MongoDB
      apt:
        name: mongodb
        state: present
        update_cache: yes

    - name: Update mongod.conf to listen on all interfaces
      block:
        - name: Change bindIp in mongod.conf
          lineinfile:
            path: /etc/mongodb.conf
            regexp: '^bind_ip = 127\.0\.0\.1$'
            line: 'bind_ip = 0.0.0.0'
            backrefs: yes

        - name: Restart MongoDB
          systemd:
            name: mongodb
            state: restarted
            daemon_reload: yes

        - name: Wait for MongoDB to restart
          wait_for:
            port: 27017
            timeout: 15

```

sudo ansible-playbook install-mongodb.yml --syntax-check

```yaml
# config-mongodb.yml
---
- name: Configure MongoDB Server
  hosts: db
  gather_facts: yes
  become: true

  tasks:
    - name: Update mongod.conf to listen on all interfaces
      block:
        - name: Change bindIp in mongodb.conf
          lineinfile:
            path: /etc/mongodb.conf
            regexp: '^bind_ip = 127\.0\.0\.1$'
            line: 'bind_ip = 0.0.0.0'
            backrefs: yes

        - name: Restart MongoDB
          systemd:
            name: mongodb
            state: restarted
            daemon_reload: yes

        - name: Wait for MongoDB to restart
          wait_for:
            port: 27017
            timeout: 15


```

sudo ansible-playbook config-mongodb.yml --syntax-check

```yaml
# install-nginx.yml
---
- name: Install and Configure Nginx
  hosts: web
  gather_facts: yes
  become: true

  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Update Nginx configuration for proxy_pass
      ansible.builtin.lineinfile:
        path: /etc/nginx/sites-available/default
        regexp: '^\s*try_files \$uri \$uri/ =404;$'
        line: '        proxy_pass http://localhost:3000/;'
        backrefs: yes
      notify: restart nginx

  handlers:
    - name: restart nginx
      ansible.builtin.service:
        name: nginx
        state: restarted

```

sudo ansible-playbook install-nginx.yml --syntax-check

```yaml
# install-nodejs-run.yml

---
- name: Install dependencies and run the application in the background
  hosts: web
  gather_facts: yes
  become: true

  tasks:
    - name: Install Node.js and npm
      apt:
        name:
          - nodejs
          - npm
          - git
        state: present
        update_cache: yes

    - name: Clone the app from GitHub
      git:
        repo: https://github.com/followcrom/sta-cicd.git
        dest: /home/ubuntu/repo
        version: main
        clone: yes
        update: yes

    - name: Stop the app if it is running
      ansible.builtin.shell: pkill node || true

    - name: Set DB_HOST environment variable in .env file
      lineinfile:
        path: /home/ubuntu/repo/app/.env
        line: 'DB_HOST=mongodb://34.244.134.252:27017/posts'
        create: yes

    - name: Run npm install in the app directory
      ansible.builtin.shell: npm install
      args:
        chdir: /home/ubuntu/repo/app

    - name: Seed the database with initial data
      ansible.builtin.shell: |
        export DB_HOST='mongodb://34.244.134.252:27017/posts' && node seed.js
      args:
        chdir: /home/ubuntu/repo/app/seeds

    - name: Start the application in the background
      ansible.builtin.shell: |
        export DB_HOST='mongodb://34.244.134.252:27017/posts' && nohup npm start > /dev/null 2>&1 &
      args:
        chdir: /home/ubuntu/repo/app
      async: 10
      poll: 0

```
sudo ansible-playbook config-mongodb.yml --syntax-check

You can run multiple Ansible playbooks sequentially with a single command by using the ansible-playbook command and listing each playbook file separated by spaces:

```bash
sudo ansible-playbook playbook1.yml playbook2.yml playbook3.yml
```



## Move files from controller to local machine

This moves a file from EC2 to local. Ensure the .pem key has been added local machine.

```bash
scp ubuntu@ec2-52-211-185-87.eu-west-1.compute.amazonaws.com:/etc/ansible/hosts /home/followcrom/projects/sta_cicd
```