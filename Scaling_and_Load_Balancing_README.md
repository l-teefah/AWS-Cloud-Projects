
# **Scaling and Load Balancing Your Architecture**

## **Overview**
This guide explains how to set up an Auto Scaling architecture using Elastic Load Balancing (ELB) and Amazon EC2 Auto Scaling. You will also create an AMI, configure a launch template, and monitor the performance of your infrastructure using Amazon CloudWatch.

---

## **Objectives**

1. Create an AMI from an EC2 instance.

2. Configure an Auto Scaling group to manage EC2 instances.

3. Use ELB for load balancing traffic.

4. Use CloudWatch alarms to monitor infrastructure performance.

5. Create the necessary resources if missing.

---

## **Prerequisites**
Ensure you have access to the AWS Management Console and permission to create EC2 instances, security groups, Auto Scaling groups, and load balancers.

---

## **Setup Needed Resources**

### **Create VPC, IGW, Route Table and Subnets**:
1. **Navigate to VPC in the AWS Management Console.**
   - Choose Create VPC.
   - Configure:
     - Name: `Practice VPC`
     - IPv4 CIDR block: 10.0.0.0/16
     - Choose Create VPC.

2. **Navigate to Subnets in the VPC dashboard.**
   - Create two subnets:
     **Subnet 1:**
     - Name: `Public Subnet 1`
     - VPC: `Practice VPC`
     - CIDR block: 10.0.1.0/24
     - Availability Zone: Select any available AZ in your preferred region.
     **Subnet 2:**
     - Name: `Public Subnet 2`
     - VPC: `Practice VPC`
     - CIDR block: 10.0.3.0/24
   - Ensure both subnets are marked as public by enabling auto-assignment of public IP addresses:
     - Select the subnet and choose Edit Subnet Settings.
     - Enable Auto-assign public IPv4.

3. **Navigate to Internet Gateways.**
   - Choose Create Internet Gateway.
     - **Name**: `Practice Internet Gateway`
   - Attach it to `Practice VPC`.

4. **Navigate to Route Tables in the VPC dashboard.**
   - Create a route table:
     - **Name**: `Practice Route Table`
     - **VPC**: `Practice VPC`
   - Edit routes:
     - Add a route to allow traffic to the internet:
     - Destination: 0.0.0.0/0
   - **Target**: Select the `Practice Internet Gateway`.
   - Associate this route table with `Public Subnet 1` and `Public Subnet 2`.

### **Create Web Security Group**
1. **Navigate to Security Groups:**
   - Open the EC2 dashboard and select **Security Groups** from the left panel.
   - Click **Create Security Group**.

2. **Configure the security group:**
   - **Name:** `Web Security Group`
   - **Description:** `Allows HTTP access to the web server`
   - **VPC:** Select the same VPC used for `Web Server`.

3. **Add inbound rules:**
   - **HTTP:**
     - **Type:** HTTP
     - **Port Range:** 80
     - **Source:** Anywhere (0.0.0.0/0)
     
   - **SSH:**
     - **Type:** SSH
     - **Port Range:** 22
     - **Source:** My IP

4. **Save and attach:**
   - Save the security group.
   - Attach it to the `Web Server` instance by navigating to **Instances**, selecting `Web Server`, and changing the associated security group under **Actions > Security**.

### **Create Web Server Instance**
1. **Navigate to EC2:**
   - Go to the **AWS Management Console** and search for **EC2**.
   - Click **Launch Instance**.

2. **Configure the instance:**
   - **Name:** `Web Server`
   - **AMI:** Select `Amazon Linux 2 AMI`.
   - **Instance Type:** Choose `t3.micro` (or any available instance type).
   - **Key Pair:** Proceed without a key pair.
   - **Network Settings:**
     - Enable **Auto-assign public IP**.
     - Use default VPC or create a new one.
   - **Storage:** Leave the default storage size (8 GiB EBS volume).
   - **User Data:** Add the following script:
    
    ```bash
     #!/bin/bash
     yum update -y
     yum install -y httpd
     systemctl start httpd
     systemctl enable httpd
     echo "<html><h1>Welcome to Web Server 1</h1></html>" > /var/www/html/index.html
     ```

3. **Launch the instance:**
   - Verify that the instance launches successfully and enters the `Running` state with status check at `3/3`.

---

## **Main Tasks**

### **Task 1: Create an AMI**
1. Navigate to **Instances** in the EC2 dashboard.
2. Select the **Web Server** instance.
3. Click **Actions > Image and templates > Create image**.
4. Configure the image:
   - **Name:** `Web Server AMI`
   - **Description:** `AMI for Auto Scaling`
5. Click **Create image** and note the AMI ID.

---

### **Task 2: Create a Load Balancer**
1. Navigate to **Load Balancers** in the EC2 dashboard.
2. Click **Create load balancer** and choose **Application Load Balancer**.
3. Configure the load balancer:
   - **Name:** `PracticeELB`
   - **Network Mapping:** Select the `Practice VPC` and map to two public subnets.
   - **Security Group:** Attach the `Web Security Group`.
4. Configure routing:
   - Create a **Target Group** (name - `practice-target-group`) and associate it with `Web Server` instance.
   - Attach the target group to the load balancer.
5. Click **Create load balancer**.

---

### **Task 3: Create a Launch Template**
1. Navigate to **Launch Templates** in the EC2 dashboard.
2. Click **Create launch template**.
3. Configure the template:
   - **Name:** `practice-app-launch-template`
   - **AMI:** Use `Web Server AMI`.
   - **Instance Type:** `t3.micro`.
   - **Security Group:** Attach `Web Security Group`.
4. Save the template.

---

### **Task 4: Create an Auto Scaling Group**
1. Navigate to the launch template and select **Create Auto Scaling group**.
2. Configure the group:
   - **Name:** `Practice Auto Scaling Group`
   - **Network:** Attach private subnets.
   - **Load Balancer:** Attach `PracticeELB`.
   - **Desired Capacity:** 2
   - **Maximum Capacity:** 4
3. Set scaling policies:
   - Enable target tracking to maintain 50% average CPU utilization.
4. Save the group.

---

### **Task 5: Verify Load Balancing**
1. Navigate to **Target Groups**.
2. Check the health status of the targets under `practice-target-group`.
3. Access the load balancer's DNS name in a browser to verify traffic routing.

---

### **Task 6: Test Auto Scaling**
1. Use **CloudWatch Alarms** to simulate CPU load.
2. Access the **Load Test application** and trigger high CPU usage.
3. Monitor new instance creation in the EC2 dashboard.

---

### **Task 7: Terminate Web Server 1**
1. Navigate to the **Web Server** instance.
2. Click **Actions > Instance state > Terminate**.

---

## **Optional Task: Creating an AMI using AWS CLI**
1. Use **EC2 Instance Connect** to connect to one of the instances created by the Auto Scaling group.
   
2. Configure AWS CLI credentials with `aws configure`, refer to Task 5 in [Install & Configure AWS CLI](Install_Configure_AWS_CLI_README.md).
   
3. Use the `aws ec2 create-image` command below to create an AMI from the instance.
     
     ```bash
     aws ec2 create-image 
     --instance-id <instance-id> 
     --name "CLI-created-AMI" 
     --description "Created using AWS CLI"
      ```

---

## **Potential Issues and Preventative Measures**

Ensure all resources (VPC, subnets, security groups, etc.) are created before starting the tasks to avoid failures during resource creation.

**Incorrect Security Group Configuration**: The Web Security Group ensures that HTTP (port 80) and SSH (port 22) traffic are allowed, fulfilling the requirements for web access and management.

**Subnet Accessibility**: Public subnets are used for the load balancer, ensuring external accessibility **while** private subnets are used for Auto Scaling instances, which are accessed through the load balancer.

**Missing AMI**: The AMI is created explicitly in Task 1. Ensuring the instance is running and properly configured before creating the AMI will prevent issues.
Resource Dependencies:

--- 
