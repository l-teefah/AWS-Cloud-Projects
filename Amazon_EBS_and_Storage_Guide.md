# Amazon Elastic Block Store (Amazon EBS) and Managing Storage Guide

## Overview
This guide combines instructions for managing Amazon Elastic Block Store (Amazon EBS) and advanced storage management using AWS Command Line Interface (CLI). You will learn how to:

1. Create and manage EBS volumes.
2. Create and manage snapshots of EBS volumes.
3. Sync files from EBS volumes to Amazon Simple Storage Service (Amazon S3) buckets.
4. Use S3 versioning to recover deleted files.

---

## Prerequisites
1. Access to the AWS Management Console and CLI.
2. Sufficient permissions to manage EC2 instances, EBS volumes, S3 buckets, and IAM roles.

---

## Section 1: Working with Amazon EBS
### Objectives
1. Create and attach an EBS volume to an EC2 instance.
2. Create and configure a file system on the EBS volume.
3. Create and restore EBS snapshots.

### Task 1: Creating and Configuring an EBS Volume
#### Steps
1. Open the EC2 Management Console.
2. Navigate to **Instances** and launch a new EC2 instance with a key pair file; I will be using [this key pair file](Resources/my_key_pair.pem). Make sure your EC2 instance's security group allows `HTTP` (port 80), `HTTPS` (port 443), and `SSH` (port 22) access access through its inbound rule. 
3. Note the **Availability Zone** of your instance (e.g., `us-west-2a`).
4. Navigate to **Volumes** under **Elastic Block Store** and click **Create Volume**.
   - Volume Type: General Purpose SSD (gp2).
   - Size: 1 GiB.
   - Availability Zone: Match your instance’s availability zone.
   - Tags: Key = Name, Value = My Volume.
5. Click **Create Volume** and ensure the status changes to **Available**.

#### Attaching the Volume to an Instance
1. Select the newly created volume.
2. Click **Actions > Attach Volume** and choose your instance.
3. Confirm the device name (e.g., `/dev/sdf`) (**because AWS may suggest a device name like `/dev/sdf` when attaching the volume**) and click **Attach Volume**.

#### Connecting and Configuring the File System
1. Use **EC2 Instance Connect** to access your instance.
2. Format the volume as `ext4`:

   ```bash
   sudo mkfs -t ext4 /dev/sdf
   ```
   
3. Create a mount directory:

   ```bash
   sudo mkdir /mnt/data-store
   ```
   
4. Mount the volume:

   ```bash
   sudo mount /dev/sdf /mnt/data-store
   echo "/dev/sdf   /mnt/data-store ext4 defaults,noatime 1 2" | sudo tee -a /etc/fstab
   ```
   
5. Verify and test the configuration:

   ```bash
   df -h
   sudo sh -c "echo sample data > /mnt/data-store/sample.txt"
   cat /mnt/data-store/sample.txt
   ```

### Task 2: Creating and Managing Snapshots
#### Taking a Snapshot
1. Identify the EBS Volume ID using the AWS CLI and **note the `volume-id`, `snapshot ID` from the result**:

   ```bash
   aws ec2 describe-volumes 
   --query 'Volumes[?Tags[?Key==`Name` && Value==`My Volume`]].{ID:VolumeId}'
   ```
2. Create a snapshot of the volume, replace `VOLUME-ID` with the value recorded earlier:

   ```bash
   aws ec2 create-snapshot 
   --volume-id VOLUME-ID
   ```
   
3. Check the snapshot status, replace `SNAPSHOT-ID` with the value recorded earlier:

   ```bash
   aws ec2 describe-snapshots 
   --snapshot-ids SNAPSHOT-ID
   ```

#### Restoring from a Snapshot
1. Use the snapshot to create a new volume, replace `SNAPSHOT-ID` with the value recorded earlier and change the region if your instance is launched in another region:

   ```bash
   aws ec2 create-volume 
   --availability-zone us-west-2a 
   --snapshot-id SNAPSHOT-ID
   ```
   
2. Attach and mount the new volume as per the earlier instructions.

---

## Section 2: Advanced Storage Management with AWS CLI
### Objectives
1. Use AWS CLI to automate snapshot management.
2. Sync EBS volume content to an Amazon S3 bucket.

### Task 1: Automating Snapshot Creation
#### Setting Up Snapshot Scheduling
1. Schedule snapshots using `cron`:

   ```bash
   echo "* * * * * aws ec2 create-snapshot 
   --volume-id VOLUME-ID >> /tmp/snapshot.log 2>&1" > cronjob
   crontab cronjob
   ```
   
2. Verify snapshots are being created:

   ```bash
   aws ec2 describe-snapshots 
   --filters "Name=volume-id,Values=VOLUME-ID"
   ```

#### Limiting Snapshot Retention
1. Use the `snapshotter_v2.py` script to retain only the last two snapshots:

   ```bash
   python3 snapshotter_v2.py
   ```
   
2. Verify snapshot cleanup:

   ```bash
   aws ec2 describe-snapshots 
   --filters "Name=volume-id,Values=VOLUME-ID"
   ```

### Task 2: Syncing Files to Amazon S3
#### Create an S3 Bucket
1. Open the **S3 Management Console** and create a bucket.
2. Activate versioning, **replace `S3-BUCKET-NAME` with your bucket name**:

   ```bash
   aws s3api put-bucket-versioning 
   --bucket S3-BUCKET-NAME 
   --versioning-configuration Status=Enabled
   ```

#### Sync Files
1. **Using Local File [samplefiles.zip](samplefiles.zip):**
   - Locate the file in your local directory: e.g.,`<path directory>/samplefiles.zip`.
   
   - Extract the file from your pc & Transfer it to the EC2 instance using `scp` in your local SSH Client, :
   
     ```bash
     cd ~/<path directory>
     chmod 400 my_key_pair.pem
     ls -l <path directory>/my_key_pair.pem
     scp -i <path directory>/my_key_pair.pem <path directory>/samplefiles.zip ec2-user@<INSTANCE_PUBLIC_IP>:/home/ec2-user/
     ```
     
**Replace `<path directory>` with your key pair file directory and `<INSTANCE_PUBLIC_IP>` with the instance's public IP**

2. **Extract the File on EC2 Instance:**
   - Go back to the EC2 instance connect tab:
   
     ```bash
     ssh -i <path directory>/my_key_pair.pem ec2-user@<INSTANCE_PUBLIC_IP
     ```
     
**Replace `<path directory>` with with your key pair & website folder directory and `<INSTANCE_PUBLIC_IP>` with the instance's public IP**
     
   - Navigate to the directory containing the file:
   
     ```bash
     cd /home/ec2-user/
     ```
     
   - Extract the ZIP file:
   
     ```bash
     unzip samplefiles.zip
     ```

3. **Sync Files to S3 Bucket:**
   - Sync the extracted files to S3, **replace `S3-BUCKET-NAME` with your bucket name**:
   
     ```bash
     aws s3 sync . s3://S3-BUCKET-NAME/
     ```

4. Enable deletion sync, **replace `S3-BUCKET-NAME` with your bucket name**:

   ```bash
   aws s3 sync . s3://S3-BUCKET-NAME/ --delete
   ```

#### Restore Deleted Files
1. List object versions, **replace `S3-BUCKET-NAME` with your bucket name** and record the `VersionId` from the result:

   ```bash
   aws s3api list-object-versions 
   --bucket S3-BUCKET-NAME 
   --prefix files/sample1.txt
   ```
   
2. Retrieve a specific version, **replace `S3-BUCKET-NAME` with your bucket name and `VERSION-ID` with the version-id recorded earlier**:

   ```bash
   aws s3api get-object 
   --bucket S3-BUCKET-NAME 
   --key files/sample1.txt 
   --version-id VERSION-ID sample1.txt
   ```
   
3. Re-upload the restored file, **replace `S3-BUCKET-NAME` with your bucket name**:

   ```bash
   aws s3 sync . s3://S3-BUCKET-NAME/
   ```

4. Verify that a new version of sample1.txt was pushed to the S3 bucket, **replace `S3-BUCKET-NAME` with your bucket name**:

   ```bash
   aws s3 ls s3://S3-BUCKET-NAME/files/
   ```

---

## **Additional Resources**
- [Amazon Elastic Block Store (Amazon EBS)](https://aws.amazon.com/ebs/)

- [Connect to Your Linux Instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html)
