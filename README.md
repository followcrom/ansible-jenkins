Creaat an SSH key pair for the GitHub repository. 
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Add the SSH key to the ssh-agent. 
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/<private_key>
```

Add the public SSH key to the GitHub account. 

Settings -> Deploy keys -> Add deploy key


## Set up a Jenkins job

From the Jenkins dashboard, click on "New Item" to create a new job.

Configure the job:

Discard old builds -> Max to keep 3
Add GitHub repository URL (https)
Source code management: Git -> repository URL (ssh)
Add private SSH key to Jenkins; should match the public key in your GitHub repository
Build triggers: GitHub hook trigger for GITScm polling
Build environment: Provide Node & npm bin/ folder to PATH
Build: Execute shell -> cd app, npm install, npm test
Save the job configuration.

To run the job, click on Build Now from the job page.

From build history, you can see the status of the build and view the console output.

## Create a dev branch on Git

Create a new branch on Git called dev.

```bash
git checkout -b dev
```

Push the dev Branch to GitHub
To push your new dev branch to GitHub, use the git push command with the -u option to set the upstream for your branch:

```bash
git push -u origin dev
```

This command pushes your local dev branch to the remote repository (referred to as origin) and sets it to track the remote dev branch. After executing this command, the dev branch will be created on GitHub if it doesn't already exist.

How to create a Webhook on GitHub
Go to your GitHub repository.
Click on Settings.
Click on Webhooks.
Click on Add webhook.
Enter the Payload URL (http://<url>>/github-webhook/).
Select the Content type as application/json.
Select "Just the push event". Make sure the "Active" box is checked.
Click on Add webhook.
NOTE for Jenkins: In the "Build Triggers" section, check the option "GitHub hook trigger for GITScm polling".

## Jenkins push to AWS VM

Create a new job in Jenkins.
Configure the job:
Discard old builds -> Max to keep 3
Add GitHub repository URL (https)
Source code management: Git -> repository URL (ssh)
Add private SSH key to Jenkins; should match the public key in your GitHub repository
Branches to build: */main
Build environment: SSH Agent -> Credentials -> Specific credentials -> tech257
Build: Execute shell ->
ssh -o "StrictHostKeyChecking=no" ubuntu@<public I.P> <<EOF
	sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt-get install nginx -y
    sudo systemctl restart nginx
Save the job configuration.