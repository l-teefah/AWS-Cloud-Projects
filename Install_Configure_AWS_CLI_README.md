# Install and Configure the AWS CLI

## Overview

The AWS Command Line Interface (CLI) is a tool that allows you to interact with AWS services from the command line. This guide outlines the process of installing and configuring the AWS CLI on a Linux environment and using it to interact with AWS Identity and Access Management (IAM).

---

## Objectives

- Install and configure the AWS CLI.
- Connect the AWS CLI to an AWS account.
- Access and manage IAM using the AWS CLI.

---

## Steps
### 1. Connect to AWS and Generate a PEM File

#### **Generate and Download a PEM File in AWS**

1. **Log in to the AWS Management Console:**
   - Navigate to [AWS Management Console](https://aws.amazon.com/console/).

2. **Navigate to EC2 Service:**
   - In the AWS Console, search for **EC2** and open the EC2 dashboard.

3. **Create a Key Pair:**
   - Go to **Key Pairs** under the **Network & Security** section on the left-hand menu.
   - Click **Create Key Pair**.
   - Enter a **name** for the key pair (e.g., `my_key_pair`).
   - Select the **PEM** format (suitable for Linux/macOS systems or OpenSSH on Windows).
   - Click **Create Key Pair**.

4. **Download the PEM File:**
   - The private key file (e.g., `my_key_pair.pem`) will be downloaded automatically. **Save this file securely**, as AWS will not allow you to download it again.

5. **Set File Permissions on the PEM File:**
   - Before using the PEM file, ensure it has the correct permissions:
   - Connect via SSH through `Terminal` or `Putty`:
   
     ```bash
     chmod 400 <my_key_pair>.pem
     ```
---

**If you are using default security group to create the EC2 instance in the next task, make sure to add inbound rule to allow SSH access on `Anywhere IPv4` or `Your IP`. If you will be creating a new security group, make sure to create the inbound rule**

### 2. Launch and Connect to an AWS EC2 Instance

1. **Go Back to the EC2 Dashboard:**
   - Under the **Instances** section, click **Launch Instances**.

2. **Select an AMI (Amazon Machine Image):**
   - Choose an Amazon Linux AMI, Ubuntu, or any other Linux distribution.

3. **Choose an Instance Type:**
   - Select an instance type (e.g., `t3.micro` for the free tier).

4. **Configure Key Pair for the Instance:**
   - During the setup process, select the **existing key pair** (`my_key_pair`) that you just created. This links the PEM file to the instance.

5. **Launch the Instance:**
   - Complete the setup and launch the instance.

6. **Obtain the Public IP Address:**
   - Go to the **Instances** section in the EC2 dashboard.
   - Select your instance and copy its **Public IPv4 address**.

### 3. Connect to the Server
1. **For Windows Users:**
   - Use `PuTTY` or a similar SSH client to connect.
   
2. **For Mac Users:**
   - Use `Terminal` to connect.
   
3. **For Linux/Mac Users:**
   - Use `ssh` to connect to the server:
   
     ```bash
     ssh -i <my_key_pair.pem> ec2-user@<server-ip-address>
     ```
     
4. Ensure the `.pem` file has the correct permissions:
   
     ```bash
     chmod 400 <my_key_pair.pem>
     ```
---

### 4. Install the AWS CLI
1. Download the AWS CLI installer:

   ```bash
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   ```

2. Extract the downloaded file:

   ```bash
   unzip -u awscliv2.zip
   ```

3. Install the AWS CLI:

   ```bash
   sudo ./aws/install
   ```

4. Verify the installation:

   ```bash
   aws --version
   ```

---

### 5. Configure the AWS CLI
1. Run the following command to configure the AWS CLI:

   ```bash
   aws configure
   ```
   
2. Enter the following details when prompted:
   - **AWS Access Key ID:** Obtain the ID from your AWS IAM user by selecting or creating a user in IAM and display the user summary. On the Security Credentials tab, click Create Access Key for **CLI** use case. Record both the Access key ID and secret access key, and download the . csv file for later use..
   - **AWS Secret Access Key:** Obtain from your AWS IAM user by the same step explained above.
   - **Default Region:** e.g., `us-west-2`.
   - **Default Output Format:** `json`.

---

### 6. Use the AWS CLI to Interact with IAM
1. List all IAM users:

   ```bash
   aws iam list-users
   ```

2. To download a policy document:

   ```bash
   aws iam list-policies 
   --scope Local
   ```
   
**Replace `<policy-arn>` & `<version-id>` with the respective values gotten from the previous code**

   ```bash
   aws iam get-policy-version 
   --policy-arn <policy-arn> 
   --version-id <version-id>
   ```
   
   ```bash
   lab_policy.json
   ```
---

## **Additional Resources**
- [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

- [AWS CLI IAM Command Reference](https://docs.aws.amazon.com/cli/latest/reference/iam/index.html)

