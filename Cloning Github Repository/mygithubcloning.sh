#!/bin/bash

# Update all installed packages to the latest versions to ensure system security and stability
sudo yum update -y

# Install Git, a version control system, to clone and manage repositories
sudo yum install git -y

# Install Apache (httpd), a web server, to serve the website files
sudo yum install httpd -y

# Navigate to the default Apache web directory, where website files are served
cd /var/www/html

# Create a new directory named 'website' in the home folder and navigate into it
mkdir ~/website && cd ~/website

# Clone the provided GitHub repository into the 'website' directory
git clone https://github.com/ummatamanna/summerschoolexercise03.git

# Navigate into the cloned repository directory
cd summerschoolexercise03

# Move all files from the cloned repository to the Apache web directory for hosting
sudo mv * /var/www/html/

# Restart the Apache web server to apply changes and make the website accessible
sudo systemctl restart httpd

