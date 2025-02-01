# **Malware Protection Using AWS Network Firewall**

## Overview
This guide outlines how to set up malware protection using AWS Network Firewall. The goal is to block access to malicious websites that users might inadvertently visit. 

## Scenario
A company has identified that employees are unknowingly downloading malware from specific websites. As a security engineer, your task is to configure a network firewall that prevents access to these malicious sites.

## Objectives
- Create and configure an AWS Network Firewall from scratch.
- Set up firewall rules to block malicious URLs.
- Validate that the firewall is working as expected.

---

## Prerequisites
Before starting, ensure you have:
- An AWS account with necessary permissions (IAM role with VPC, EC2, and Network Firewall access).
- Basic knowledge of AWS services like VPC, EC2, and IAM.

---

## Step 1: Set Up an EC2 Instance (Test Instance)
1. Go to **AWS Console** > **EC2** > **Launch Instance**.
2. Set the instance name as `SecurityTestInstance`.
3. Select **Amazon Linux 2** as the OS.
4. Choose an appropriate instance type (e.g., t2.micro).
5. Configure networking:
   - Create a new VPC (e.g., `SecurityVPC`).
   - Create a subnet (e.g., `SecuritySubnet`).
   - Assign a security group allowing SSH access (Port 22).
6. Under **Advanced Details**, enable **AWS Systems Manager** for remote access.
7. Click **Launch Instance**.

---

## Step 2: Set Up AWS Network Firewall
1. Navigate to **VPC Console** > **Network Firewall** > **Create Firewall**.
2. Configure the firewall:
   - **Firewall Name:** `SecurityFirewall`
   - **VPC:** Select `SecurityVPC`.
   - **Availability Zone:** Choose an appropriate one.
   - **Subnet:** Select `SecuritySubnet`.
   - Click **Create Firewall**.

3. Create a firewall policy:
   - Go to **VPC**, then **Firewall Policies** under **Network Firewall**, then **Create Firewall Policy**.
   - Name it `SecurityFirewallPolicy`.
   - Under **Stateless default actions**, choose **Forward to stateful rule groups**.
   - Click **Create Policy**.

4. Associate the policy with the firewall:
   - Go to **Firewalls** > Select `SecurityFirewall`.
   - Under **Associated Firewall Policy**, choose `SecurityFirewallPolicy`.

---

## Step 3: Create a Firewall Rule Group
1. Navigate to **Network Firewall Rule Groups** > **Create Rule Group**.
2. Configure the rule group:
   - **Name:** `MalwareBlockRules`
   - **Type:** Stateful rule group
   - **Rule format:** Suricata compatible rules
   - **Rule Evaluation Order:** Choose Action order.
   - **Capacity:** 100
   - Click **Next**.

3. In the Suricata compatible IPS rules section, copy and paste the following rules into the text box to block malicious URLs:

```
drop http $HOME_NET any -> $EXTERNAL_NET 80 (msg:"MALWARE Block Rule"; flow:to_server,established; classtype:trojan-activity; sid:2002001; content:"/data/js_crypto_miner.html";http_uri; rev:1;)

drop http $HOME_NET any -> $EXTERNAL_NET 80 (msg:"MALWARE Block Rule"; flow:to_server,established; classtype:trojan-activity; sid:2002002; content:"/data/java_jre17_exec.html";http_uri; rev:1;)
```

4. Click Next a few times until you reach the Review and Create page then click **Create Stateful Rule Group**.

---
## Step 4: Attach Rule Group to the Firewall
1. Go to **Firewalls** > **SecurityFirewall**.
2. Select **SecurityFirewallPolicy**.
3. Under **Stateful Rule Groups**, choose **Add Stateful Rule Group**.
4. Select `MalwareBlockRules` and click **Add**.
5. Click **Save Changes**.

---

## Step 5: Validate the Firewall
1. Connect to the EC2 instance (`SecurityTestInstance`) using AWS Systems Manager:
   - Go to **EC2 Console** > **Instances** > Select `SecurityTestInstance`.
   - Click **Connect** > **Session Manager** > **Connect**.
2. Run the following commands to check malware accessibility:

```
wget http://malware.wicar.org/data/js_crypto_miner.html
wget http://malware.wicar.org/data/java_jre17_exec.html
```

3. The output should indicate that access is blocked.

4. Remove test files (if any were downloaded):

```
rm java_jre17_exec.html js_crypto_miner.html
```

5. Confirm that the files were deleted by running:

```
ls
```

---

**Next Steps:**
- Monitor firewall logs to track attempted accesses.
- Expand rule sets to cover more threats.
- Integrate AWS Security Hub for additional threat intelligence.
