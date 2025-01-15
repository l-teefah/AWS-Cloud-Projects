# AWS CLI Commands for Troubleshooting a VPC

# Task 1: Configure AWS CLI
aws configure

# Task 2: Create VPC Flow Logs

## Create S3 Bucket
aws s3api create-bucket --bucket flowlog###### --region 'us-west-2' --create-bucket-configuration LocationConstraint='us-west-2'

## Get VPC ID
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value,CidrBlock]' --filters "Name=tag:Name,Values='VPC1'"

## Create VPC Flow Logs
aws ec2 create-flow-logs --resource-type VPC --resource-ids <vpc-id> --traffic-type ALL --log-destination-type s3 --log-destination arn:aws:s3:::<flowlog######>

## Verify Flow Logs
aws ec2 describe-flow-logs

# Task 3: Troubleshooting Challenges

## Challenge #1: Web Server Access Issues

### Analyze Web Server Instance
aws ec2 describe-instances --filter "Name=ip-address,Values='<WebServerIP>'" --query 'Reservations[*].Instances[*].[State,PrivateIpAddress,InstanceId,SecurityGroups,SubnetId,KeyName]'

### Check Open Ports
sudo yum install -y nmap
nmap <WebServerIP>

### Analyze Security Group
aws ec2 describe-security-groups --group-ids <WebServerSgId>

### Validate Route Table
aws ec2 describe-route-tables --filter "Name=association.subnet-id,Values='<VPC1PubSubnetID>'"
aws ec2 create-route --route-table-id <route-table-id> --destination-cidr-block 0.0.0.0/0 --gateway-id <gateway-id>

## Challenge #2: SSH Access Issues

### Analyze Network ACL
aws ec2 describe-network-acls --filter "Name=association.subnet-id,Values='<VPC1PubSubnetID>'" --query 'NetworkAcls[*].[NetworkAclId,Entries]'

### Delete Network ACL Entry
aws ec2 delete-network-acl-entry --network-acl-id <acl-id> --rule-number <rule-number>

# Task 4: Analyzing Flow Logs

## Download Flow Logs
mkdir flowlogs
cd flowlogs
aws s3 cp s3://<flowlog######>/ . --recursive
gunzip *.gz

## Analyze Logs

### Find Rejected Events
grep -rn REJECT .

### Refine Search for Port 22
grep -rn 22 . | grep REJECT

### Confirm Network Interface ID
aws ec2 describe-network-interfaces --filters "Name=association.public-ip,Values='<WebServerIP>'" --query 'NetworkInterfaces[*].[NetworkInterfaceId,Association.PublicIp]'

### Convert Timestamps
# Example: date -d @<timestamp>
date -d @<timestamp>

date
