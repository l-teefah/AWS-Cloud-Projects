
# Amazon Route 53 Failover Routing

## Overview

In this tutorial, you will configure failover routing for a simple web application hosted on two Amazon EC2 instances, each deployed in separate Availability Zones. Using Amazon Route 53, the setup ensures that traffic is automatically routed to a secondary instance if the primary instance becomes unavailable. This setup helps maintain high availability for the application.

---

## Objectives

By completing this tutorial, you will:

1. Move files from your pc to an EC2 instance.
2. Configure a Route 53 health check that triggers email notifications when a primary endpoint becomes unhealthy.
2. Set up failover routing in Route 53 to ensure application traffic is rerouted to a secondary instance in case of primary instance failure.

---

## Prerequisites

### Required Resources

1. **Sewing Website**: A web application similar to a sewing-related platform is ready.
2. **Sewing Website Instances**: Two Amazon EC2 instances pre-configured with the LAMP stack and the application running.
3. **Domain Name**: A Route 53 domain (e.g., `sewing-example.com`) for DNS routing.

### Setting Up Resources

#### Prepare Website Files for Deployment

1. **Directory Structure**:

   - The website files are organized as follows:
   
     ```
     /sewing-website
       ├── index.php
       ├── style.css
       ├── images/
       ├── includes/
     ```
     
   - `index.php`: The main webpage.
   - `style.css`: Stylesheet for sewing website.
   - `images/`: Folder containing website images.
   - `includes/`: Contains header files for reusability.

2. **Compress Files**:

   - The entire `sewing-website` folder is zipped for easy transfer, the zipped file is available at [Sewing Website Zipped Folder](sewing-website.zip)

#### Deploy Sewing Website on EC2 Instances

1. **Launch Two EC2 Instances**:

   - Name - `SewingInstance1` and `SewingInstance2`
   - Choose Amazon Linux 2 AMI as the OS.
   - Allocate `t3.micro` for low-cost hosting.
   - Allow inbound rules on your preferred security group (whether default or new) from `HTTP` (port 80), `HTTPS` (port 443), and `SSH` (port 22) access. 
   - Place the 2 instances in different Availability Zones (e.g., `us-west-2a` and `us-west-2b`). You can do this by editing `Network settings` during the instance launch and then `Subnet` to assign preferred availability zone.
   
2. **Move the Website Files Folder to the EC2 Instances**:

   - The codes in this step is executed from SSH client (`Terminal`or `Putty`) as [the key pair](my_key_pair.pem) and [sewing website folder](sewing-website.zip) are located on my pc and they need to be moved to the EC2 instance first. Remember that all the steps are done seperately for each instance.

   - Assuming your key pair file is in the downloads folder, if not, replace `~/Downloads` with the file directory.
   
     ```bash
     cd ~/Downloads
     ```
     
   - Check key file permissions.

     ```bash
     chmod 400 my_key_pair.pem
     ```
     
   - Verify the file permissions with (replace `path directory` with the key pair file directory:

     ```bash
     ls -l <path directory>/my_key_pair.pem
     ```

   - Transfer the zipped files to both EC2 instances using `scp` (replace `<path directory>` with with your key pair & website folder directory and `<INSTANCE_PUBLIC_IP>` with each instance's public IP):
   
     ```bash
     scp -i <path directory>/my_key_pair.pem <path directory>/sewing-website.zip ec2-user@<INSTANCE_PUBLIC_IP>:/home/ec2-user/
     ```

3. **SSH Connect To Instances**:

   - Continue using `Terminal` or `Putty` by running the code below to connect to the EC2 instances directly. Alternatively, SSH into both instances using EC2 Instance Connect, if you will be using EC2 instance connect you don't need to run the code below, you can move on to the next step.
   
     ```bash
     ssh -i my_key_pair.pem ec2-user@<INSTANCE_PUBLIC_IP>
     ```
     
   - Confirm the website folder is present in the instances
   
      ```bash
      ls
      ```
   
   - Update packages and install required software by running the command below.
   
      ```bash
      sudo yum update -y
      sudo yum install httpd php php-mysqlnd mariadb-server -y
      sudo systemctl start httpd
      sudo systemctl enable httpd
     ````
     
   - Unzip the files in sewing folder and move files to `/var/www/html` (apache directory):
   
      ```bash
      unzip sewing-website.zip
      sudo mv sewing-website/* /var/www/html/
      ```

   - Ensure correct ownership and permissions for Apache (for both instances):
   
     ```bash
     sudo chown -R apache:apache /var/www/html
     sudo chmod -R 755 /var/www/html
     ```

4. **Test the Deployment**:

   - Access the instances public IP seperately in a browser to confirm the website is live.
   
**N.B: If there is any error message when accessing the public IP, remove the 's' at the end of 'http' in the browser link and reload the page.**

#### Create a Domain Name

1. **Register a Domain**:

   - Navigate to the Route 53 console and register a domain (e.g., `sewing-example.com`).
   - Cost Implication: Domain registration typically costs $12-$50 per year depending on the TLD.

2. **Create a Hosted Zone**:

   - In Route 53, create a hosted zone for the domain.
   - Note the name servers assigned and ensure the domain points to these servers.

---

## Tutorial Steps

### Step 1: Confirm the Sewing Websites

1. Open the AWS Management Console and navigate to **EC2**.
2. Verify two EC2 instances (`SewingInstance1` and `SewingInstance2`) are running in separate Availability Zones.
3. Access the applications by pasting the instance public URLs into a browser to confirm they display the sewing website.

### Step 2: Configure a Route 53 Health Check

1. Navigate to **Route 53** > **Health checks**.
2. Create a health check for the primary instance:
   - **Name**: `Primary-Website-Health`
   - **IP Address**: Public IPv4 of `SewingInstance1`
   - **Path**: `/sewing`
   - **Advanced Configurations**:
     - Request interval: `Fast (10 seconds)`
     - Failure threshold: `2`
   - Enable email notifications by creating a new SNS topic with your email address.
3. Confirm the health check is operational by checking the Monitoring tab.
4. Verify your email subscription for notifications.

### Step 3: Configure Route 53 Records

#### Task 3.1: Create an A Record for the Primary Website

1. Navigate to **Hosted Zones** in Route 53.
2. Create a new A record with:
   - **Record Name**: `www`
   - **Value**: Public IPv4 of `SewingInstance1`
   - **Routing Policy**: `Failover`
   - **Failover Type**: `Primary`
   - **Health Check**: `Primary-Website-Health`
3. Save the record.

#### Task 3.2: Create an A Record for the Secondary Website

1. Create another A record with:
   - **Record Name**: `www`
   - **Value**: Public IPv4 of `SewingInstance2`
   - **Routing Policy**: `Failover`
   - **Failover Type**: `Secondary`
   - Leave **Health Check** empty.
2. Save the record.

---

### Step 4: Verify DNS Resolution

1. Copy the domain name (e.g., `www.sewing-example.com`) and append `/sewing` to the URL.
2. Load the page in a browser to verify the primary website loads correctly.

### Step 5: Test Failover Functionality

1. Stop the primary EC2 instance (`SewingInstance1`) from the EC2 console.
2. Wait until the primary health check shows `Unhealthy` in Route 53.
3. Refresh the browser page for the domain. Confirm the website now loads from the secondary instance.
4. Check your email for health check alerts.

---

## **Cost Implications**

- **EC2 Instances**: Running two `t3.micro` instances under the free tier.
- **Route 53 Hosted Zone**: $0.50 per month.
- **Health Checks**: $0.50 per month per health check.
- **Domain Registration**: $12-$50 per year depending on the domain TLD.

---

## **Additional Resources**

- [Amazon Route 53 Health Checks](https://aws.amazon.com/route53/health-checks/)

- [Amazon Route 53 Failover Routing](https://aws.amazon.com/route53/faqs/)

---

