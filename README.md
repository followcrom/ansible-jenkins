# Sparta CI/CD App

Insane in the membrane.

## Create an SSH key pair for the GitHub repository 
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Add the SSH key to the ssh-agent. 
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/<private_key>
```

Add the public SSH key to the GitHub repo. 

`Repo -> Settings -> Deploy keys -> Add deploy key`

<br>

# Git / GitHub

## Create a dev branch on Git

Because we are going to test on the dev branch, we need to create a new branch on Git.

```bash
git checkout -b dev
```

Push the _dev_ branch to GitHub.

```bash
git push -u origin dev
```

This command pushes your local dev branch to the remote repository (referred to as origin) and sets it to track the remote dev branch. -u is for -upstream. This is useful for when you want to push changes to the remote branch in the future.

## Create a Webhook on GitHub

1. Go to your GitHub repository.
2. Click on Settings.
3. Click on Webhooks.
4. Click on Add webhook.
5. Enter the Payload URL: http://<url>>/github-webhook/
6. Select the Content type as application/json.
7. Select "Just the push event". Make sure the "Active" box is checked.
8. Click on Add webhook.

**NOTE for Jenkins**: In the "Build Triggers" section, check the option "GitHub hook trigger for GITScm polling".

<br>

# Jenkins

From the Jenkins dashboard, click on "New Item" to create a new job.

To run the job, click on **Build Now** from the job page.

From build history, you can see the status of the build and view the **console output**.

## Jenkins job 1: Run tests on dev

**Configure the job**:
- Discard old builds -> Max to keep 3
- GitHub project -> project URL (https)
- Restrict where this project can be run -> sparta-ubuntu-node
- Source code management: Git -> repository URL (ssh)
- Credentials should match the public key in your GitHub repository
- Branches to build: */dev
- Build triggers: GitHub hook trigger for GITScm polling
- Build environment: Provide Node & npm bin/ folder to PATH
- Build: Execute shell -> `cd app, npm install, npm test`
- Post-build actions: _merge dev into main_

<br>

## Jenkins job 2: Merge dev with main

**Configure the job**:
- Discard old builds -> Max to keep 3
- GitHub project -> project URL (https)
- Source code management: Git -> repository URL (ssh)
- Credentials should match the public key in your GitHub repository
- Branches to build: */dev. (This is to merge the dev branch with the main branch.)
- Post-build actions -> Git Publisher:
    - Push only if build succeeds
    - Merge results
    - Force push (is this necessary?)
    - Branch to push: main
    - Target remote name: origin. (origin is the default name of the remote repository.)

<br>

## Jenkins job 3: Push to AWS VM (CDE)

**Configure the job**:
- Discard old builds -> Max to keep 3
- GitHub project -> project URL (https)
- Source code management: Git -> repository URL (ssh)
- Credentials should match the public key in your GitHub repository
- Branches to build: */main (This is to deploy the main branch to the AWS VM.)
- Build environment: SSH Agent -> Credentials -> Specific credentials -> tech257
- Build: Execute shell ->

```bash
rsync -avz -e "ssh -o StrictHostKeyChecking=no" app ubuntu@3.255.247.13:/home/ubuntu/
rsync -avz -e "ssh -o StrictHostKeyChecking=no" environment ubuntu@3.255.247.13:/home/ubuntu/

ssh -o "StrictHostKeyChecking=no" ubuntu@3.255.247.13 <<EOF
    sudo apt-get update -y
    sudo apt-get upgrade -y

    sudo apt-get install nginx -y

    sudo systemctl restart nginx
    sudo systemctl enable nginx
    
    cd ~/appenvironment/app
    chmod +x provision.sh
    ./provision.sh
    
    cd ~/app
    npm install
EOF
```

**Note** that the folders from GitHub are in the Jenkins **Workspace**. These are referenced in the rsync commands, where they are copied to the AWS VM.

**Note** still need to run npm start on the AWS VM.

## Jenkins job 3: Push to AWS VM (CD)

**Configure the job**:
- Discard old builds -> Max to keep 3
- GitHub project -> project URL (https)
- Source code management: Git -> repository URL (ssh)
- Credentials should match the public key in your GitHub repository
- Branches to build: */main (This is to deploy the main branch to the AWS VM.)
- Build environment: SSH Agent -> Credentials -> Specific credentials -> tech257
- Build: Execute shell ->

```bash
rsync -avz -e "ssh -o StrictHostKeyChecking=no" app ubuntu@3.255.96.158:/home/ubuntu/

ssh -o "StrictHostKeyChecking=no" ubuntu@3.255.96.158 <<EOF
    cd ~/app
    pkill -f node
    npm install
    nohup node app.js > /dev/null 2>&1 &
EOF
```

**Note** that the folders from GitHub are in the Jenkins **Workspace**. These are referenced in the rsync commands, where they are copied to the AWS VM.

<br>

# Build a Jnekins server on AWS

## Step 1: Launch an EC2 Instance
Select an AMI: Choose an Amazon Machine Image (AMI) for your instance. A common choice is to start with a basic Linux distribution like Ubuntu or Amazon Linux 2.
Choose an Instance Type: Select an appropriate instance type based on your needs. For small projects or testing, a t2.micro might be sufficient, which is eligible for the free tier.
Configure Instance: Configure your instance details. The defaults are often fine for a basic setup, but ensure your network and subnet settings are correct for your VPC.
Add Storage: Adjust the storage size if necessary. The default should be enough to get started, but you might need more depending on your projects.
Configure Security Group: Create a new security group with rules allowing SSH access (port 22) from your IP, and TCP access on port 8080, which Jenkins uses by default.
Review and Launch: Review your settings and launch the instance. Choose an existing key pair or create a new one to SSH into the instance.

## Step 2: Install Jenkins

SSH into your EC2 instance using its public IP

# Install Java
```bash
sudo apt install openjdk-11-jdk -y
```

## Install Jenkins
```bash
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
```

## Start Jenkins
```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```


# How to open VS Code from the terminal

Launching VS Code from an environment where your SSH agent is running ensures that all child processes, including Git operations initiated from the Source Control panel, inherit the SSH authentication context, thus avoiding permission issues with remote repositories over SSH.

`code .`

If you're not in the directory of your project, replace `.` with the path to your project directory.