**Github Cloning Deployment Process on AWS**

This repository documents the process of deploying a website on an AWS EC2 instance, including cloning an existing repository, configuring the environment, and hosting the application using Apache. 

**Project Overview**
This repository contains:
1. The steps and commands used to clone and deploy a website on an AWS EC2 instance.
2. Documentation of the tools and configurations required for the deployment.
3. A `mygithubcloning.sh` script that automates the deployment process.

---

**Repository Contents**

**`mygithubcloning.sh`**: A shell script containing all the commands required for deployment.

**`README.md`**: Documentation of the deployment process.

---

**Deployment Process**
Below is a step-by-step guide to deploying a website on an AWS EC2 instance:

1. **Set Up the EC2 Instance**
   - Launch an AWS EC2 instance using the Amazon Linux 2 AMI.
   - Ensure ports 22 (SSH) and 80 (HTTP) are open in the security group.

2. **Update the System**
   
   ```bash
   sudo yum update -y
   ```

3. **Install Required Packages**
   
   ```bash
   sudo yum install git -y
   sudo yum install httpd -y
   ```

4. **Clone the Repository**
   Navigate to the desired directory and clone the GitHub repository:
   
   ```bash
   git clone https://github.com/l-teefah/AWS-Cloud-Computing-Classes.git
   cd AWS-Cloud-Computing-Classes
   ```

5. **Deploy the Website**
   Move the website files to the Apache root directory:
   
   ```bash
   sudo mv * /var/www/html/
   sudo systemctl restart httpd
   ```

6. **Access the Website**
   Open your browser and navigate to the public IP of the EC2 instance to view the deployed website.

---

**Prerequisites**

**AWS Account**: To create and configure an EC2 instance.

**Git**: To clone the repository.

**Basic Linux Knowledge**: To execute shell commands.

---

**How to Use This Repository**

Use the `process.sh` script to automate the deployment:

   ```bash
   chmod +x mygithubcloning.sh
   ./mygithubcloning.sh
   ```

---

**Contributing**
If you’d like to contribute, feel free to e-mail me, submit a pull request or raise an issue.

---

**Author**
**Name**: Lateefah Yusuf
**GitHub**: https://github.com/l-teefah

---
