
# **AWS User, Groups and Directory Guide Instructions**

This README provides a comprehensive set of step-by-step guides designed to help perform essential tasks on an AWS environment from scratch. Each guide walks through connecting to an EC2 instance, managing users and groups, working with files and directories, monitoring processes, and automating repetitive tasks using cron jobs.

Whether you're new to AWS or looking to solidify your skills, these instructions provide practical, hands-on experience with core AWS concepts and Linux commands. You will learn how to:

- Create and manage users and groups.
- Organize and restructure directories and files.
- Back up data and log critical details.
- Monitor system processes.
- Automate tasks for efficiency.

---

### **Prerequisites**

## Set Up and Connect to an EC2 Instance

### Step 1: Create an EC2 Instance
1. Go to the AWS Management Console.
2. Navigate to the EC2 service and launch a new instance.
   - Choose a Linux-based AMI (e.g., Amazon Linux 2).
   - Select an instance type (e.g., t3.micro).
   - Configure instance details and security groups to allow SSH access (port 22).
3. Generate a new key pair during setup (e.g., `key_pair.pem`).
4. Download the `.pem` file and save it securely.

### Step 2: Configure SSH Connection

#### **Windows Users**
1. Download PuTTY from its [official website](https://www.putty.org/).
2. Convert `.pem` to `.ppk` using PuTTYgen:
   - Open PuTTYgen, load the `.pem` file, and save it as `.ppk`.
3. Open PuTTY and configure the session:
   - Hostname: `<public-ip>` (Replace with the EC2 instance’s public IP address.)
   - SSH > Auth: Browse and load the `.ppk` file.
   - Connection: Set keepalives to 30 seconds.
4. Click **Open**, log in as `ec2-user` when prompted.

#### **macOS and Linux Users**
1. Open a terminal.
2. Navigate to the directory containing the `.pem` file and edit `~/Downloads` with the path to the key pair file:

   ```bash
   cd ~/Downloads
   ```
   
3. Set appropriate permissions:

   ```bash
   chmod 400 <key_pair.pem>
   ```
   
**Replace `<key_pair.pem>` with the name of your key pair file.**
  
4. Connect to the EC2 instance:

   ```bash
   ssh -i key_pair.pem ec2-user@<public-ip>
   ```
   
**Replace `<public-ip>` & `key_pair.pem` with the public IP address of the EC2 instance and name of your key pair file.**

---


### **Section 1: Users and Groups**

#### Objectives
- Create new users with default passwords.
- Create groups and assign users.
- Log in as different users.

## **User List Table**

| First Name | Last Name   | User ID      | Job Role            | Password          | Group     |
|------------|-------------|--------------|---------------------|-------------------|-----------|
| Carlos     | Fernandez   | cfernandez   | Marketing Manager   | P@ssword2025      | Managers  |
| Amina      | Khan        | akhan        | IT Specialist       | P@ssword2025      | IT        |
| John       | Smith       | jsmith       | Operations Manager  | P@ssword2025      | Managers  |
| Yuki       | Takahashi   | ytakahashi   | Data Analyst        | P@ssword2025      | IT        |
| Fatima     | Ahmed       | fahmed       | HR Specialist       | P@ssword2025      | HR        |
| Omar       | Suleiman    | osuleiman    | Product Manager     | P@ssword2025      | Managers  |
| Lila       | Lopez       | llopez       | Sales Associate     | P@ssword2025      | Sales     |
| Ravi       | Patel       | rpatel       | Software Developer  | P@ssword2025      | IT        |
| Emily      | Johnson     | ejohnson     | Finance Analyst     | P@ssword2025      | Finance   |
| Zara       | Ali         | zali         | Customer Support    | P@ssword2025      | Personell |


1. Create users using `useradd` and set their passwords using `passwd`. Replace `<username>` & `<password>` with appropriate User ID and password from the table above. 

   ```bash
   sudo useradd <username>
   sudo passwd <password>
   ```

2. Validate users:

   ```bash
   sudo cat /etc/passwd | cut -d: -f1
   ```

3. Create groups using `groupadd`, replace `<group_name>` with each group:

   ```bash
   sudo groupadd <group_name>
   ```

4. Add users to groups, replace `<group_name>` & `<username>` with appropriate group name and username respectively for each entry in the table e.g., `sudo usermod -a -G Managers cfernandez`:

   ```bash
   sudo usermod -a -G <group_name> <username>
   ```

5. Validate group memberships:

   ```bash
   sudo cat /etc/group
   ```

6. Switch users using, replace `<username>` with any username:

   ```bash
   su <username>
   ```

7. Verify permissions and sudo access. Ensure unauthorized sudo commands are logged.

---

## **Section 2: Working with AWS File System**

### Objectives
- Create a folder structure.
- Create, move, and delete files and directories.

### Steps

#### 1. **Create a Folder Structure**

1. Navigate to the home directory:

   ```bash
   cd /home/ec2-user
   ```

2. Create directories and files:

   ```bash
   mkdir -p MyCompany/{Accounting,HumanResources,Leadership}
   touch MyCompany/Accounting/{FinancialStatements.csv,Payroll.csv}
   touch MyCompany/HumanResources/{PerformanceReviews.csv,Onboarding.csv}
   touch MyCompany/Leadership/{Executives.csv,Meetings.csv}
   ```

3. Validate the structure:

   ```bash
   ls -laR MyCompany
   ```


#### 2. **Reorganize Folder Structure**

1. Copy and move directories:

   ```bash
   cp -r MyCompany/Accounting MyCompany/HumanResources
   mv MyCompany/Leadership MyCompany/HumanResources
   ```

2. Create a new `TeamMembers` folder in `HumanResources` directory and move files between the directories:

   ```bash
   mkdir MyCompany/HumanResources/TeamMembers
   mv MyCompany/HumanResources/{PerformanceReviews.csv,Onboarding.csv} MyCompany/HumanResources/TeamMembers
   ```

3. Verify:

   ```bash
   ls -laR MyCompany
   ```

---

## **Section 3: Working with Files**

### Objectives
- Create a tar backup of a folder structure.
- Log backup creation details.
- Move the backup file to another folder.


#### 1. **Create a Backup**

1. Navigate to the home directory and validate the folder structure:

   ```bash
   cd /home/ec2-user
   mkdir -p MyCompany/Shared #creation of Shared directory to store backup data
   ls -R MyCompany
   ```

2. Create a tar backup:

   ```bash
   tar -cvpzf backup.MyCompany.tar.gz MyCompany
   ```

3. Validate the backup file:

   ```bash
   ls
   ```


#### 2. **Log Backup Details**

1. Create a `backups.csv` file in `Shared` folder:

   ```bash
   touch MyCompany/Shared/backups.csv
   ```

2. Log the backup creation:

   ```bash
   echo "$(date), backup.MyCompany.tar.gz" | sudo tee MyCompany/Shared/backups.csv
   ```

3. Display log contents:

   ```bash
   cat MyCompany/Shared/backups.csv
   ```


#### 3. **Move the Backup File**

1. Move the backup to from `Shared` to `Leadership` folder:

   ```bash
   mv backup.MyCompany.tar.gz MyCompany/Leadership
   ```

2. Verify the file transfer:

   ```bash
   ls MyCompany/Leadership
   ```

---

## **Section 4: Managing Processes**

### Objectives
- Create a new log file for process listings.
- Use the `top` command to monitor active processes.
- Establish a repetitive task using a cron job.

#### 1. **Create a List of Processes**

1. Navigate to the correct directory:

   ```bash
   cd /home/ec2-user/MyCompany
   ```

2. Create a log file of non-root processes:

   ```bash
   sudo ps -aux | grep -v root | sudo tee Shared/processes.csv
   ```

3. Validate the log file:

   ```bash
   cat Shared/processes.csv
   ```


#### 2. **Monitor Processes with the `top` Command**

1. Run the `top` command:

   ```bash
   top
   ```

2. Observe the system performance and active processes.

3. Exit `top` by pressing `q`.

#### 3. **Create a Cron Job**

1. Open the crontab editor:

   ```bash
   sudo crontab -e
   ```

2. Add the following cron job:

   ```bash
   SHELL=/bin/bash
   PATH=/usr/bin:/bin:/usr/local/bin
   MAILTO=root
   0 * * * * ls -la $(find .) | sed -e 's/..csv/#####.csv/g' > /home/ec2-user/MyCompany/Shared/filteredAudit.csv
   ```

3. Save and exit the editor.

4. Verify the cron job:

   ```bash
   sudo crontab -l
   ```
   
---

## **AWS Component Information**

- **Amazon EC2**: t3.micro instance (1 vCPU, 1 GiB memory) used for these guides.

---

## Additional Resources

- [Amazon EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)

- [Amazon Machine Images (AMI)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)

- [AWS Training and Certification](https://aws.amazon.com/training/)

---


