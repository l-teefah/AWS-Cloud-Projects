# **AWS Data Protection and IAM Setup**

## Overview

This guide provides step-by-step instructions to set up AWS resources for data protection using encryption and identity access management (IAM). The setup includes creating encryption keys, managing IAM users and groups, and implementing security policies.

## Objectives

- Created and managed an AWS KMS encryption key.
- Configured an EC2 instance for encryption operations.
- Installed and used AWS Encryption CLI to encrypt and decrypt data.
- Created IAM users, groups, and policies to enforce least privilege access.
- Tested user permissions to validate the IAM setup.

## Prerequisites

- An AWS account
- AWS CLI installed and configured
- Administrator permissions in AWS Management Console

## **Section 1: Data Protection Using Encryption**

### Step 1: Create an AWS KMS Encryption Key
1. Open the AWS Management Console.
2. In the search bar, enter `KMS` and select **Key Management Service**.
3. Click **Create a Key**.
4. Select **Symmetric** as the key type and click **Next**.
5. Add the following details:
   - **Alias:** `ProjectEncryptionKey`
   - **Description:** `Encryption key for securing project files.`
6. Click **Next** and configure administrative permissions.
7. Assign permissions to an IAM user or role.
8. Click **Finish**, choose the link for `ProjectEncryptionKey`, and copy the **Key ARN** for later use.

### Step 2: Set Up an EC2 Instance for Encryption
1. Open the AWS Management Console.
2. Navigate to **EC2** and launch a new instance.
3. Select an Amazon Linux 2 AMI.
4. Choose an instance type (e.g., t2.micro).
5. Configure security groups to allow SSH (port 22) access.
6. Attach an IAM role with KMS permissions.
7. Launch the instance and connect using AWS Session Manager.

### Step 3: Install AWS Encryption CLI
1. Connect to the EC2 instance using **AWS Session Manager**.
2. Run the following commands:

   ```sh
   cd ~
   pip3 install aws-encryption-sdk-cli
   export PATH=$PATH:/home/ec2-user/.local/bin
   ```

### Step 4: Encrypt and Decrypt Data
1. Create sample text files:

   ```sh
   touch confidential1.txt
   echo 'CONFIDENTIAL DATA' > confidential1.txt
   ```
   
2. Encrypt the file using KMS, replace `<KMS_ARN>` with the **Key ARN** copied in Step 1:

   ```sh
   aws-encryption-cli --encrypt \
     --input confidential1.txt \
     --wrapping-keys key=<KMS_ARN> \
     --metadata-output ~/metadata \
     --encryption-context purpose=test \
     --commitment-policy require-encrypt-require-decrypt \
     --output confidential1.txt.encrypted
   ```
To determine whether the command succeeded, run the following command:

   ```sh
   echo $?
   ls
   ```

3. Decrypt the file, replace `<KMS_ARN>` with the **Key ARN** copied in Step 1:

   ```sh
   aws-encryption-cli --decrypt \
     --input confidential1.txt.encrypted \
     --wrapping-keys key=<KMS_ARN> \
     --commitment-policy require-encrypt-require-decrypt \
     --encryption-context purpose=test \
     --metadata-output ~/metadata \
     --max-encrypted-data-keys 1 \
     --buffer \
     --output confidential1.txt.decrypted
   ```
   
4. To view the new file location and view the contents of the decrypted file, run the following command:

   ```sh
   ls
   cat confidential1.txt.decrypted
   ```

## **Section 2: Introduction to AWS Identity and Access Management (IAM)**

### Step 1: Create an IAM Password Policy
1. Search **IAM** in AWS Console.
2. Navigate to **Account Settings**.
3. Click **Change Password Policy**.
4. Set the following parameters:
   - **Minimum password length:** `12`
   - **Require at least one uppercase letter, number, and special character**
   - **Prevent password reuse for last 6 passwords**
5. Click **Save Changes**.

### Step 2: Create IAM Users and Groups
1. Open **IAM**.
2. Navigate to **User Groups** and create the following groups:
   - `Project-Admin`
   - `Project-Support`
   - `Data-Support`
3. Assign permissions for each groups:
   - `Project-Admin`: `EC2-Admin-Policy`policy
   - `Project-Support`: `AmazonEC2ReadOnlyAccess` policy
   - `Data-Support`: `AmazonS3ReadOnlyAccess` policy
4. Navigate to **Users**, create the following users and the groups for each users are indicated in parenthesis:
   - `analyst-1` (Data-Support)
   - `analyst-2` (Project-Support)
   - `engineer-1` (Project-Admin)
5. Add users to their respective groups as indicated above.

### Step 3: Test IAM User Permissions
1. Open an **Incognito/Private Browsing** window.
2. Navigate to the IAM sign-in URL for your AWS account.
3. Log in as `analyst-1`, `analyst-2`, and `engineer-1` using the IAM sign-in URL for each users(remember to logout from each before moving on to the next user), and verify their access:
   - `analyst-1` should only access S3 but not EC2.
   - `analyst-2` should only view EC2 instances but not stop/start them.
   - `engineer-1` should be able to stop/start EC2 instances.

---

For further details, refer to the official [AWS Documentation](https://docs.aws.amazon.com/).
