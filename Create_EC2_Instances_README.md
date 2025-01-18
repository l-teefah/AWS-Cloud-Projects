# Creating Amazon EC2 Instances

## Overview

This guide explains how to launch Amazon EC2 instances using the AWS Management Console and AWS CLI. You will:

- Create a bastion host using the AWS Management Console.
- Connect to the bastion host using EC2 Instance Connect.
- Launch a web server instance using the AWS CLI.

---

## Objectives
- Launch an EC2 instance via the AWS Management Console.
- Connect to the EC2 instance using EC2 Instance Connect.
- Launch a web server instance using AWS CLI.

---

## Steps

### Task 1: Launch an EC2 Instance via the AWS Management Console
1. Open the **EC2 Management Console**.
2. Select **Launch instance** and configure the following:
   - **Name:** Bastion host
   - **AMI:** Amazon Linux 2
   - **Instance Type:** t3.micro
   - **Key Pair:** Proceed without key pair
   - **Network Settings:** Select `default VPC` and `Public Subnet`.
   - **Security Group:** Name it `Bastion security group` and permit SSH connections.
   - **Storage:** Keep the default 8 GiB.
   - **IAM Role:** Select `Bastion-Role`.
3. Review the configuration and launch the instance.

---

### Task 2: Connect to the Bastion Host
1. In the **EC2 Management Console**, select the bastion host instance.
2. Choose **Connect** and use **EC2 Instance Connect**.
3. Once connected, you can use the AWS CLI to manage AWS resources.

---

### Task 3: Launch a Web Server Instance Using AWS CLI
1. **Retrieve Necessary Parameters**:
   - AMI ID: 
   
     ```bash
     AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
     export AWS_DEFAULT_REGION=${AZ::-1}
     AMI=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --query 'Parameters[0].[Value]' --output text)
     echo $AMI
     ```
     
   - Subnet ID:
   
     ```bash
     SUBNET=$(aws ec2 describe-subnets --filters 'Name=tag:Name,Values=Public Subnet' --query Subnets[].SubnetId --output text)
     echo $SUBNET
     ```
     
   - Security Group ID:
   
     ```bash
     SG=$(aws ec2 describe-security-groups --filters Name=group-name,Values=WebSecurityGroup --query SecurityGroups[].GroupId --output text)
     echo $SG
     ```
     
2. **Download User Data Script**:

   ```bash
   wget https://example.com/UserData.txt
   cat UserData.txt
   ```
   
   This script installs and configures the web server.
   
3. **Launch the Instance**:

   ```bash
   INSTANCE=$(aws ec2 run-instances    --image-id $AMI    --subnet-id $SUBNET    --security-group-ids $SG    --user-data file:///home/ec2-user/UserData.txt    --instance-type t3.micro    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Web Server}]'    --query 'Instances[*].InstanceId'    --output text)
   echo $INSTANCE
   ```
   
4. **Check the Instance Status**:

   ```bash
   aws ec2 describe-instances --instance-ids $INSTANCE --query 'Reservations[].Instances[].State.Name' --output text
   ```
   
5. **Retrieve the Web Server URL**:

   ```bash
   aws ec2 describe-instances --instance-ids $INSTANCE --query Reservations[].Instances[].PublicDnsName --output text
   ```

---

## Additional Resources
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/reference/)

- [Amazon EC2 User Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/)

