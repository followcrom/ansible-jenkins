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

