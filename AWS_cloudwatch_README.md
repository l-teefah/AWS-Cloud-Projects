# **Monitor an EC2 Instance with AWS CloudWatch and SNS**

## Overview
This guide explains how to set up monitoring for an Amazon EC2 instance using AWS CloudWatch and Amazon SNS. By the end of this guide, there will be an automated alert system that notifies via email when CPU utilization exceeds a set threshold. Additionally, we will create a CloudWatch dashboard to visualize the instance’s CPU usage.

## Prerequisites
Before starting, ensure you have the following:
- An **AWS account** with necessary permissions to create EC2 instances, IAM roles, SNS topics, and CloudWatch alarms.
- A valid **email address** for receiving notifications.

## Steps to Set Up Monitoring
### 1. Create an EC2 Instance
1. Log in to the [AWS Management Console](https://aws.amazon.com/console/).
2. Navigate to **EC2** and click **Launch Instance**.
3. Configure the following:
   - **Name**: `MonitoringInstance`
   - **Amazon Machine Image (AMI)**: Choose `Amazon Linux 2`
   - **Instance type**: `t3.micro`
   - **Key pair**: Create or select an existing key pair
   - **Network settings**: Ensure SSH access is enabled for the security group attached to the instance
   - **IAM Role**: Create an IAM role with `AmazonSSMManagedInstanceCore` permissions
   - **Storage**: Default settings are sufficient
4. Click **Launch Instance**.

### 2. Configure Amazon SNS (Simple Notification Service)
1. In the **AWS Management Console**, navigate to **SNS**.
2. Choose **Create topic**.
3. Configure the topic:
   - **Type**: `Standard`
   - **Name**: `MyCloudwatchAlarm`
4. Click **Create topic**.
5. Under the **Subscriptions** tab, click **Create subscription**.
6. Configure the subscription:
   - **Topic ARN**: Select `MyCloudwatchAlarm`
   - **Protocol**: `Email`
   - **Endpoint**: Enter your valid email address
7. Click **Create subscription**.
8. Confirm your subscription by checking your email and clicking the confirmation link.

### 3. Create a CloudWatch Alarm
1. In the **AWS Management Console**, navigate to **CloudWatch**.
2. Under **Metrics**, choose **EC2 -> Per-Instance Metrics**.
3. Select the check box next to **CPUUtilization** for your instance.
4. Click **Create Alarm** and configure:
   - **Threshold**: `Greater than 60%`
   - **Period**: `1 minute`
   - **SNS Notification**: Select `MyCloudwatchAlarm`
   - **Alarm Name**: `CWAlarm`
5. Click **Create alarm**.

### 4. Stress Test the EC2 Instance
1. Connect to the EC2 instance using SSH or AWS Systems Manager Session Manager.
2. Run the following command to simulate high CPU usage:

   ```sh
   sudo stress --cpu 10 -v --timeout 400s
   ```
   
3. Open another terminal session and run:

   ```sh
   top
   ```
   
   This command displays real-time CPU usage.
4. Navigate back to **CloudWatch Alarms** and refresh until the alarm status changes to `In alarm`.
5. Check your email for an SNS notification alerting you of the high CPU utilization.

### 5. Create a CloudWatch Dashboard
1. Navigate to **CloudWatch**.
2. Under **Dashboards**, choose **Create dashboard**.
3. Enter a **Dashboard Name**: `CWDashboard`
4. Choose **Line Chart -> Metrics**.
5. Select **EC2 -> Per-Instance Metrics**.
6. Choose **CPUUtilization** for your instance.
7. Click **Create widget** and **Save dashboard**.

---

## **Cleanup**
To avoid unnecessary charges, delete the following when done:

- **EC2 Instance** (`MonitoringInstance`)

- **CloudWatch Alarm** (`CWAlarm`)

- **SNS Topic** (`MyCloudwatchAlarm`)

- **CloudWatch Dashboard** (`CWDashboard`)


## **Additional Resources**

- [AWS CloudWatch Documentation](https://docs.aws.amazon.com/cloudwatch/)

- [AWS SNS Documentation](https://docs.aws.amazon.com/sns/)

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)

---

