
# Understanding and Deploying the Lateefah CloudFormation Template

## Overview
AWS CloudFormation simplifies the process of defining and provisioning infrastructure (IaaC) by using templates written in JSON or YAML. This guide provides a detailed explanation of how the CloudFormation template works and step-by-step instructions for uploading and deploying the [file template](CloudFormation Template/Lateefah CloudFormation Template.yaml) using two methods: the AWS Management Console and an SSH terminal.

---

## How the Template Works

### Structure of a CloudFormation Template
A CloudFormation template is divided into several sections:

1. **Parameters:**
   - Used to accept user input during stack creation.
   - Example:
     ```yaml
     Parameters:
       InstanceType:
         Type: String
         Default: t2.micro
         Description: EC2 instance type
     ```

2. **Resources:**
   - Defines the AWS resources to be provisioned, such as EC2 instances, S3 buckets, or VPCs.
   - Example:
     ```yaml
     Resources:
       MyEC2Instance:
         Type: AWS::EC2::Instance
         Properties:
           InstanceType: !Ref InstanceType
           ImageId: ami-0abcdef1234567890
     ```

3. **Outputs:**
   - Provides information about created resources, such as their IDs or URLs.
   - Example:
     ```yaml
     Outputs:
       InstanceId:
         Description: ID of the EC2 instance
         Value: !Ref MyEC2Instance
     ```

4. **Mappings, Conditions, and Metadata:**
   - Used for advanced configurations (optional).

### Features of **Lateefah CloudFormation Template.yaml**
- Provisions a Virtual Private Cloud (VPC) with subnets.
- Creates an Amazon S3 bucket for storage.
- Launches an EC2 instance with user-defined instance type and security groups.
- Outputs details such as VPC ID, EC2 instance ID, and S3 bucket name.

---

## Method 1: Upload Using AWS Management Console

1. **Log in to the AWS Management Console**
   - Navigate to the AWS CloudFormation service.

2. **Create a New Stack**
   - Click on **Create stack** > **With new resources (standard)**.

3. **Upload the Template File**
   - Choose the option **Upload a template file**.
   - Click **Choose file** and select **Lateefah CloudFormation Template.yaml** from your local system.

4. **Configure Stack Details**
   - Provide a unique stack name (e.g., `MyStack`).
   - Input parameters (if applicable) as prompted by the template.

5. **Configure Stack Options** (optional)
   - Add tags, set permissions, or configure advanced options as needed.

6. **Review and Deploy**
   - Review the configuration summary.
   - Acknowledge that CloudFormation might create IAM resources if applicable.
   - Click **Create stack**.

7. **Monitor the Stack**
   - The stack status will initially display **CREATE_IN_PROGRESS**.
   - Wait until it changes to **CREATE_COMPLETE**.
   - Verify the created resources under the **Resources** tab.

---

## Method 2: Upload Using an SSH Terminal

### Move Template from PC to EC2 Instance

1. **Using Local File [CloudFormation template](Lateefah CloudFormation Template.yaml):**
   - Locate the file in your local directory: e.g.,`<path directory>/Lateefah CloudFormation Template.yaml`.
   
   - Launch a new EC2 instance with a key pair file; I will be using [this key pair file](my_key_pair.pem). Make sure your EC2 instance's security group allows `SSH` (port 22) access access through its inbound rule.
   
   - Extract the file from your pc & Transfer it to the EC2 instance using `scp` in your local SSH Client (Putty or Terminal):
   
     ```bash
     cd ~/<path directory>
     chmod 400 my_key_pair.pem
     ls -l <path directory>/my_key_pair.pem
     scp -i <path directory>/my_key_pair.pem <path directory>/Lateefah CloudFormation Template.yaml ec2-user@<INSTANCE_PUBLIC_IP>:/home/ec2-user/
     ```
     
**Replace `<path directory>` with your key pair file & template directory and `<INSTANCE_PUBLIC_IP>` with the instance's public IP**

2. **Extract the File on EC2 Instance:**
   - Connect to the EC2 instance using EC2 instance connect or continue using local SSH:
   
     ```bash
     ssh -i <path directory>/my_key_pair.pem ec2-user@<INSTANCE_PUBLIC_IP
     ```
     
**Replace `<path directory>` with with your key pair & website folder directory and `<INSTANCE_PUBLIC_IP>` with the instance's public IP**
     
   - Navigate to the directory containing the file:
   
     ```bash
     cd /home/ec2-user/
     ```
   - Confirm that the template has been transferred to the EC2 instance:
   
     ```bash
     ls
     ```

### Upload CloudFormation Template Using AWS CLI/SSH

1. **Install and Configure AWS CLI** (if not already done)
   - Install AWS CLI:
   
     ```bash
     sudo yum install aws-cli # For RHEL/CentOS
     ```
     
   - Configure the CLI:
   
     ```bash
     aws configure
     # Enter AWS Access Key, Secret Key, Region, and Output Format
     ```

2. **Create the Stack Using AWS CLI**
   - Use the following command to create the stack:
   
     ```bash
     aws cloudformation create-stack \
       --stack-name MyStack \
       --template-body file://Lateefah\ CloudFormation\ Template.yaml \
       --parameters ParameterKey=InstanceType,ParameterValue=t3.micro \
       --region us-east-1
     ```
     
   - Replace `us-east-1` with appropriate value if you will be using another region.

3. **Monitor Stack Creation**
   - Use the following command to check stack status:
   
     ```bash
     aws cloudformation describe-stacks --stack-name MyStack
     ```
     
   - Wait until the stack status is **CREATE_COMPLETE**.

4. **Verify Resources**
   - Use the AWS Management Console to verify the created resources.

---

## Cleanup
To delete the stack and its resources:
- **AWS Management Console:** Select the stack and click **Delete**.
- **AWS CLI:**

  ```bash
  aws cloudformation delete-stack --stack-name MyStack
  ```

---

## Notes
- YAML formatting is critical; maintain proper indentation and syntax.
- Always validate templates before deploying to avoid runtime errors.
- Use the **Outputs** section to extract useful resource details post-deployment.

---

## **Additional Resources**
- [AWS CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)

- [AWS CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/)

---

