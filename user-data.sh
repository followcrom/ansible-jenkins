#!/bin/bash

# Update and upgrade packages
sudo apt update -y
sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Restart and enable Nginx to run on startup
sudo systemctl restart nginx
sudo systemctl enable nginx

# Install Node.js 20.x (this also installs npm as a dependency)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

echo "Installing Node.js..."
echo

sudo apt-get install -y nodejs

echo "Node.js Installed: version: $(node -v)"
echo 

# Install pm2 globally
sudo npm install pm2@latest -g

echo "Installed pm2"

# Clone the app from GitHub
git clone https://github.com/followcrom/tech257-sparta-app.git

echo "Cloned the app from GitHub"

# Navigate to the app directory
cd tech257-sparta-app/app

export DB_HOST=mongodb://10.0.3.4:27017/posts

DB_HOST=mongodb://10.0.3.4:27017/posts

echo $DB_HOST

# Install dependencies
npm install

echo "Installing dependencies..."

echo "Installed dependencies"

NGINX_CONF_PATH="/etc/nginx/sites-available"

cd $NGINX_CONF_PATH

NGINX_CONF="default"

# Display the full path of the Nginx configuration file being edited
echo "Updating Nginx configuration in: $NGINX_CONF_PATH/$NGINX_CONF"
echo


sudo sed -i 's|try_files $uri $uri/ =404;|proxy_pass http://localhost:3000/;|' $NGINX_CONF

# Test Nginx configuration for syntax errors
if sudo nginx -t; then
    echo "Nginx configuration syntax is okay."
    sudo systemctl restart nginx
    echo "Nginx restarted successfully."
else
    echo "Error in Nginx configuration. Check the config file at $NGINX_CONF_PATH/$NGINX_CONF."
fi

echo

cd -

if pm2 list | grep -q "online"; then
    pm2 stop all
    echo "Stopped all running processes."
else
    echo "No running processes found."
fi

echo

# Use pm2 to start app and ensure it runs in the background
pm2 start app.js --name "sparta-test-app"

# Upgrade packages non-interactively, and automatically handle prompts
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Import the public key used by the package management system
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

# add the MongoDB repository to your sources list
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Install the MongoDB packages
sudo apt-get install -y mongodb-org=7.0.5 mongodb-org-database=7.0.5 mongodb-org-server=7.0.5 mongodb-org-mongos=7.0.5 mongodb-org-tools=7.0.5

sudo apt update -y

# MONGODB! Depending on the version of MongoDB installed, the service name changes from mongod to mongodb. TAKE NOTE!

# service name: mongod

sudo systemctl start mongod

sudo systemctl enable mongod

# service name: mongodb

# sudo systemctl status mongodb

# sudo systemctl stop mongodb

# sudo systemctl restart mongodb

cd /etc/

MDB_CONF="mongod.conf"

sudo cp $MDB_CONF "${MDB_CONF}.backup"

sudo nano /etc/mongod.conf

sudo sed -i 's|bindIp: 127.0.0.1|bindIp: 0.0.0.0|' $MDB_CONF

sudo systemctl restart mongod