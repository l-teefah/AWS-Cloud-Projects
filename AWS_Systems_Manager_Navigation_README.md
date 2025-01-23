# Using AWS Systems Manager

## Overview

AWS Systems Manager is a set of tools that enables centralized operational data and task automation across AWS resources, on-premises servers, and virtual machines. This guide demonstrates how to:
- Verify configurations and permissions.
- Execute tasks on multiple servers.
- Update application settings or configurations.
- Access the command line of an instance without SSH.

---

## Objectives
- Use Fleet Manager to gather inventory details.
- Deploy applications with Run Command.
- Manage application settings with Parameter Store.
- Access instances securely with Session Manager.

---

## Steps

### Task 1: Collect Inventory Using Fleet Manager
1. Navigate to **AWS Systems Manager** in the AWS Management Console.
2. In the left navigation pane, select **Inventory** under **Node Tools**.
3. Click **Set up inventory** to collect details about managed instances.
   - Provide the following details:
     - **Name:** `Inventory-Association`
     - **Target:** Selecting all managed instances in this account
4. Review the collected inventory details by selecting the managed instance and clicking the **Inventory** tab.

---

### Task 2: Install Applications with Run Command
1. In the AWS Management Console, navigate to **Systems Manager**.
2. In the left navigation pane, select **Run Command** under **Node Tools**.
3. Choose a predefined document (Choose **Owner** first, then, **Owned by me or Amazon** in the dropdown list) such as `AWS-RunShellScript`.
4. Manually select a managed instance as the target.
5. Specify installation commands, for example:
   - `sudo yum install -y httpd php`
   - `sudo systemctl start httpd`
6. Run the command and wait for the status to change to **Success**.
7. Access the instance's public IP in a browser to validate the installation.

---

### Task 3: Manage Settings with Parameter Store
1. Navigate to **Systems Manager** in the AWS Management Console.
2. Select **Parameter Store** under **Application Tools**.
3. Click **Create parameter** and fill in the following details:
   - **Name:** `/dashboard/show-alpha-features`
   - **Description:** `Display alpha features`
   - **Value:** `True`
4. Save the parameter.
5. Refresh your application in the browser to see the new features activated.
6. Optionally delete the parameter to revert changes.

---

### Task 4: Access Instances with Session Manager
1. In the AWS Management Console, navigate to **Systems Manager**.
2. In the left navigation pane, select **Session Manager** under **Node Tools**.
3. Start a session for a managed instance.
4. Run commands within the session to verify configurations:
   - List application files:
   
     ```bash
     ls /var/www/html
     ```
     
   - Fetch EC2 instance metadata:
   
     ```bash
     aws ec2 describe-instances
     ```
     
5. Confirm SSH ports are closed for enhanced security in the instance's security group.

---

For more information, visit [AWS Systems Manager Documentation](https://docs.aws.amazon.com/systems-manager).
