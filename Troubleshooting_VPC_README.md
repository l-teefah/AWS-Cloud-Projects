# Troubleshooting a VPC

## Overview
This project involves troubleshooting and resolving issues in an AWS Virtual Private Cloud (VPC) environment. It includes creating and analyzing VPC Flow Logs, fixing connectivity issues, and verifying access to resources.

### Key Features:
- Create S3 buckets for VPC Flow Logs.
- Generate and analyze VPC Flow Logs.
- Troubleshoot connectivity issues using AWS CLI.

---

## Lab Instructions

### Task 1: Set Up and AWS CLI Configuration

1. **Launch the Lab:**
   - Start the lab and access the AWS Management Console.
   - Open the CLI Host EC2 instance using EC2 Instance Connect.

2. **Configure AWS CLI:**

   ```bash
   aws configure
   ```
   Provide the following details:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region name: `us-west-2`
   - Default output format: `json`

### Task 2: Create VPC Flow Logs

1. **Create S3 Bucket for Flow Logs:**

   ```bash
   aws s3api create-bucket 
   --bucket flowlog###### 
   --region 'us-west-2' 
   --create-bucket-configuration LocationConstraint='us-west-2'
   ```

2. **Get VPC ID:**

   ```bash
   aws ec2 describe-vpcs 
   --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value,CidrBlock]' 
   --filters "Name=tag:Name,Values='VPC1'"
   ```

3. **Create Flow Logs:**

   ```bash
   aws ec2 create-flow-logs 
   --resource-type VPC 
   --resource-ids <vpc-id> 
   --traffic-type ALL 
   --log-destination-type s3 
   --log-destination arn:aws:s3:::<flowlog######>
   ```

4. **Verify Flow Logs:**

   ```bash
   aws ec2 describe-flow-logs
   ```

---

### Task 3: Troubleshooting Challenges

#### Challenge #1: Web Server Access Issues
1. **Analyze Web Server Instance:**

   ```bash
   aws ec2 describe-instances 
   --filter "Name=ip-address,Values='<WebServerIP>'" 
   --query 'Reservations[*].Instances[*].[State,PrivateIpAddress,InstanceId,SecurityGroups,SubnetId,KeyName]'
   ```

2. **Check Open Ports:**

   ```bash
   sudo yum install -y nmap
   nmap <WebServerIP>
   ```

3. **Analyze Security Group:**

   ```bash
   aws ec2 describe-security-groups --group-ids <WebServerSgId>
   ```

4. **Validate Route Table:**

   ```bash
   aws ec2 describe-route-tables 
   --filter "Name=association.subnet-id,Values='<VPC1PubSubnetID>'"
   aws ec2 create-route 
   --route-table-id <route-table-id> 
   --destination-cidr-block 0.0.0.0/0 
   --gateway-id <gateway-id>
   ```

#### Challenge #2: SSH Access Issues
1. **Analyze Network ACL:**

   ```bash
   aws ec2 describe-network-acls 
   --filter "Name=association.subnet-id,Values='<VPC1PubSubnetID>'" 
   --query 'NetworkAcls[*].[NetworkAclId,Entries]'
   ```

2. **Delete Network ACL Entry:**

   ```bash
   aws ec2 delete-network-acl-entry --network-acl-id <acl-id> --rule-number <rule-number>
   ```

---

### Task 4: Analyzing Flow Logs

1. **Download Flow Logs:**

   ```bash
   mkdir flowlogs
   cd flowlogs
   aws s3 cp s3://<flowlog######>/ . --recursive
   gunzip *.gz
   ```

2. **Analyze Logs:**

   ```bash
   grep -rn REJECT .
   grep -rn 22 . | grep REJECT
   aws ec2 describe-network-interfaces 
   --filters "Name=association.public-ip,Values='<WebServerIP>'" 
   --query 'NetworkInterfaces[*].[NetworkInterfaceId,Association.PublicIp]'
   date -d @<timestamp>
   ```

---

For advanced log analysis, consider using Amazon Athena to query flow logs. For more information, refer to AWS Training and Certification resources.
