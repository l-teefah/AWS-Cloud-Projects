# Creating Amazon EC2 Instances

## Overview

This guide demonstrates how to launch and configure Amazon EC2 instances using both the AWS Management Console and the AWS Command Line Interface (AWS CLI). By the end of this guide, you will have:
- Created a Virtual Private Cloud (VPC) for hosting EC2 instances.
- Launched an EC2 instance using the AWS Management Console.
- Connected to the instance using EC2 Instance Connect.
- Launched another EC2 instance using the AWS CLI, configured as a web server.

---

## Objectives
- Set up a VPC if none exists.
- Launch an EC2 instance via the AWS Management Console.
- Connect to an EC2 instance using EC2 Instance Connect.
- Launch and configure an EC2 instance using the AWS CLI.

---

## Steps

### **Task 1: Create a VPC**
If no pre-existing VPC is available, follow these steps:

1. **Create a VPC**:
   - Navigate to the **VPC Console** and select **Create VPC**.
   - Configure:
     - **Name**: `MyLabVPC`
     - **IPv4 CIDR Block**: `10.0.0.0/16`
     - **Tenancy**: Default
   - Click **Create VPC**.

2. **Create a Subnet**:
   - Go to **Subnets** and choose **Create Subnet**.
   - Configure:
     - **Name**: `PublicSubnet`
     - **VPC ID**: Select `MyLabVPC`.
     - **Availability Zone**: Choose one from the dropdown.
     - **IPv4 CIDR Block**: `10.0.1.0/24`
   - Click **Create Subnet**.

3. **Create an Internet Gateway**:
   - Go to **Internet Gateways** and select **Create internet gateway**.
   - Name it: `MyLabIGW`.
   - Attach the gateway to `MyLabVPC`.

4. **Update the Route Table**:
   - Navigate to **Route Tables** in the VPC Console.
   - Select the route table associated with `MyLabVPC`.
   - Add a route:
     - **Destination**: `0.0.0.0/0`
     - **Target**: `MyLabIGW`.

5. **Enable Public IP Auto-assignment**:
   - In **Subnets**, select `PublicSubnet`.
   - Go to **Actions > Modify auto-assign IP settings**.
   - Enable **Auto-assign public IPv4 address**.

---

### **Task 2: Launch an EC2 Instance Using the AWS Management Console**
1. **Access the Amazon EC2 Console**:
   - Open the EC2 Management Console and select **Launch Instance**.
2. **Configure the Instance**:
   - Name the instance `Bastion host`.
   - Use the Amazon Linux 2 AMI.
   - Select the `t3.micro` instance type.
   - Proceed without a key pair.
   - Place the instance in the **MyLabVPC** with the `PublicSubnet`.
   - Create a security group named `Bastion security group` and allow SSH connections in the inbound rule.
3. **Launch the Instance**:
   - Review the configuration and launch the instance.
   - Verify its status as `Running` and status checks as `3/3` in the EC2 console.

---

### **Task 3: Connect to the Bastion Host**
1. **Use EC2 Instance Connect**:
   - Select the bastion host instance and click **Connect**.
   - Choose **EC2 Instance Connect** and connect to the instance.
   - Once connected, you can run AWS CLI commands on the instance.

2. **Configure AWS CLI**:
   - Run the `aws configure` command:
   
     ```bash
     aws configure
     ```
     
   Provide the following details:
   - **AWS Access Key ID**: Enter your AWS access key.
   - **AWS Secret Access Key**: Enter your secret key.
   - **Default region name**: Enter `us-west-2` (or the region you're using).
   - **Default output format**: Enter `json`.
       
---

### **Task 4: Launch an EC2 Instance Using the AWS CLI**
1. **Retrieve Necessary Parameters**:
   - **AMI ID**: Use AWS Systems Manager Parameter Store to retrieve the latest Amazon Linux 2 AMI ID.
   
   ```bash
     AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
     export AWS_DEFAULT_REGION=${AZ::-1}
     AMI=$(aws ssm get-parameters 
     --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 
     --query 'Parameters[0].[Value]' 
     --output text)
     echo $AMI
     ```
     
   - **Subnet ID**: Retrieve the public subnet ID.
   
   ```bash
     SUBNET=$(aws ec2 describe-subnets 
     --filters 'Name=tag:Name,Values=Public Subnet' 
     --query Subnets[].SubnetId 
     --output text)
     echo $SUBNET
     ```
     
   - **Security Group ID**: Retrieve the ID of the security group allowing HTTP access.
   ```bash
     SG=$(aws ec2 describe-security-groups 
     --filters Name=group-name,Values=WebSecurityGroup 
     --query SecurityGroups[].GroupId 
     --output text)
     echo $SG
     ```
     
2. **Download and Review the User Data Script**:
   - Download a script to configure the web server and view its contents.
   
   ```bash
     wget https://example.com/path-to-user-data-script.txt -O /home/ec2-user/UserData.txt
     ```
   
     ```bash
     cat /home/ec2-user/UserData.txt
     ```
     
3. **Launch the Instance**:
   - Use the `aws ec2 run-instances` command below to launch the instance.
   - Specify parameters such as the AMI ID, subnet ID, security group ID, and user data script.
   
   ```bash
     INSTANCE=$(
     aws ec2 run-instances \
     --image-id $AMI \
     --subnet-id $SUBNET \
     --security-group-ids $SG \
     --user-data file:///home/ec2-user/UserData.txt \
     --instance-type t3.micro \
     --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Web Server}]' \
     --query 'Instances[*].InstanceId' \
     --output text
     )
     echo $INSTANCE
     ```
    
4. **Verify the Instance**:
   - Use the `aws ec2 describe-instances` command to monitor the instance status until it shows `running`.
   
   ```bash
     aws ec2 describe-instances 
     --instance-ids $INSTANCE 
     --query 'Reservations[].Instances[].State.Name' 
     --output text
     ```
     
   - Retrieve the public DNS name of the instance and test the web server in a browser.
   
   ```bash
     aws ec2 describe-instances 
     --instance-ids $INSTANCE 
     --query Reservations[].Instances[].PublicDnsName 
     --output text
     ```

---

For further reading, refer to:
- [Launch Your Instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/launching-instance.html)

- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
