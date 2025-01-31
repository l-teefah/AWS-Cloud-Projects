# **Network and System Hardening Using Amazon Inspector and AWS Systems Manager**

## Objectives

- Configuring Amazon Inspector to analyze network configurations.
- Implementing AWS Systems Manager Patch Manager to ensure system compliance.
- Removing unnecessary security risks by modifying security groups.
- Transitioning from a Bastion server to AWS Systems Manager Session Manager.

## Prerequisites
Ensure you have an AWS account with the necessary permissions to:
- Create and manage EC2 instances
- Modify security groups
- Configure AWS Systems Manager and Amazon Inspector
- Create IAM roles

## **Section 1: Network Hardening with Amazon Inspector**

### Step 1: Set Up Required Resources
1. **Create a Virtual Private Cloud (VPC)**
   - Navigate to **VPC** in the AWS console.
   - Click **Create VPC** and give it a name.
   - Choose **IPv4 CIDR block** (e.g., `10.0.0.0/16`).

2. **Create Subnets**
   - Create a **public subnet** (e.g., `10.0.1.0/24`).
   - Create a **private subnet** (e.g., `10.0.2.0/24`).

3. **Set Up an Internet Gateway**
   - Navigate to **Internet Gateways**.
   - Click **Create Internet Gateway**.
   - Attach the Internet Gateway to the VPC created earlier by selecting your VPC and clicking **Attach to VPC**.
   - Modify the route table for the public subnet to add a route to the internet (Destination: `0.0.0.0/0`, Target: **Internet Gateway ID**).

4. **Create Security Groups**
   - Navigate to **VPC** and then **Security group**, then create the two security groups specified below.
   - **BastionServerSG** (for a bastion host): Allow SSH (port 22) only from anywhere IPv4.
   - **AppServerSG** (for an application server):
     - Restrict public access unless explicitly needed.
     - No open SSH or RDP access from the internet.

5. **Launch EC2 Instances**
   - Create a **Bastion Server** in the public subnet using an Amazon Linux AMI.
   - Create an **Application Server** in the private subnet.
   - Attach appropriate security groups to each instance i.e., **BastionServerSG** to **BastionServer** EC2 instance and **AppServerSG** to **Application Server** EC2 instance.

### Step 2: Configure Amazon Inspector
1. Navigate to **Amazon Inspector** in the AWS Console.
2. Create an **Assessment Target** and tag the EC2 instances (e.g., `Key: SecurityScan, Value: true`).
3. Create an **Assessment Template** using the `Network Reachability-1.1` rules package.
4. Run the scan and review findings.

### Step 3: Secure the Network
1. Navigate to **EC2 > Security Groups**.
2. Select **BastionServerSG** and remove inbound SSH rule allowing access from `0.0.0.0/0`.
3. Restrict SSH access by adding only a trusted IP (`Select `My IP` for `Source type``).
4. Select **AppServerSG** and remove any rules allowing unnecessary inbound traffic.
5. Remove any open Telnet (port 23) access.
6. Run the Amazon Inspector scan again to verify security improvements.

### Step 4: Replace Bastion Server with Systems Manager
1. Attach an **IAM Role** to the AppServer with `AmazonSSMManagedInstanceCore` policy.
2. Navigate to **AWS Systems Manager > Session Manager**.
3. Enable **Session Manager** in the **Preferences** section.
4. Navigate to **EC2 > Instances**, select the **Bastion Server**, and stop the instance.
5. Use **Session Manager** to directly access the **Application Server** without SSH.
6. Confirm connectivity by running basic Linux commands in the Session Manager:

- `whoami` (checks the logged-in user)
- `ls -l` (lists files to ensure access)
- `ping google.com` (verifies network connectivity)

7. Once confirmed, permanently terminate the Bastion Server in the EC2 console.


## **Section 2: System Hardening with Patch Manager**

### Step 1: Create and Set Up EC2 Instances
1. Navigate to **EC2** in the AWS console.
2. Launch **three Linux instances** and **three Windows instances**.
3. Create and assign appropriate security groups for each instance:
   - **LinuxServerSG**: Allow inbound SSH (port 22) only from your IP (Select `My IP` for `Source type`).
   - **WindowsServerSG**: Allow inbound RDP (port 3389) only from your IP (Select `My IP` for `Source type`).
4. Attach an **IAM Role** with `AmazonSSMManagedInstanceCore` permissions to all instances.
5. Verify that the instances are running and accessible in **AWS Systems Manager > Fleet Manager** and have the IAM role attached.

### Step 2: Patch Linux Instances Using Default Baseline
1. Navigate to EC2 in the AWS console.
2. Select all Linux instances.
3. Click `Actions` > `Manage Tags`.
4. Click Add Tag and enter the following:
   - Key: `Patch Group`
   - Value: `LinuxProd`
5. Click Save.
6. Navigate to Patch Manager in AWS Systems Manager.
7. Choose Patch Now.
8. Select instances tagged with `Patch Group: LinuxProd`.
9. Choose `AWS-AmazonLinux2DefaultPatchBaseline` and apply updates.

### Step 3: Set Up Windows Patch Management

1. Navigate to **AWS Systems Manager** in the AWS console.
2. In the search bar at the top, enter **Systems Manager** and select it.
3. In the left navigation pane, under **Node Management**, choose **Patch Manager**.
4. Choose **Start with an overview** (if this option does not appear, proceed to the next step).
5. Choose the **Patch baselines** tab.
6. Choose the **Create patch baseline** button.

### Step 4: Configure Patch Baseline Details:

- **Name**: `WindowsServerSecurityUpdates`
- **Description**: *(optional)* `Windows security baseline patch`
- **Operating system**: `Windows`
- **Leave the Default patch baseline checkbox unselected.**

#### Configure Approval Rules for Operating Systems:

1. **Add First Rule**:
   - **Products**: Choose `WindowsServer2019`, then deselect `All`.
   - **Severity**: Choose `Critical`.
   - **Classification**: Choose `SecurityUpdates`.
   - **Auto-approval**: Enter `3 days`.
   - **Compliance reporting**: Choose `Critical`.

2. **Add Second Rule**:
   - **Products**: Choose `WindowsServer2019`, then deselect `All`.
   - **Severity**: Choose `Important`.
   - **Classification**: Choose `SecurityUpdates`.
   - **Auto-approval**: Enter `3 days`.
   - **Compliance reporting**: Choose `High`.

3. Choose **Create patch baseline**.

### Step 5: Associate Windows Instances with Patch Groups
1. Navigate to the **Patch baselines** section.
2. Select the `WindowsServerSecurityUpdates` patch baseline that you just created.
3. Choose the **Actions** dropdown list, then select **Modify patch groups**.
4. In the **Modify patch groups** section under **Patch groups**, enter `WindowsProd`.
5. Choose the **Add** button, then choose **Close**.

### Step 6: Patch Windows Instances
1. Navigate to EC2 in the AWS console.
2. Select all Windows instances.
3. Click `Actions` > `Manage Tags`.
4. Click Add Tag and enter the following:
   - Key: `Patch Group`
   - Value: `WindowsProd`
5. Click Save.
6. Navigate to **Patch Manager**.
7. Choose **Patch Now**.
8. Select instances tagged `WindowsProd` and apply patches.

### Step 6: Verify Compliance
1. Navigate to **Patch Manager > Compliance Reporting**.
2. Verify that all instances show as **Compliant**.
3. Review applied patches in the **Patch tab** of each instance.

---


