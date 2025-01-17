# Build Your Database Server and Interact Using an Application

## Overview

This guide walks through setting up and interacting with a relational database server using managed database services and creating a DB using MySQL. You will:

- Launch a database instance with high availability.
- Configure security to allow access from an application server.
- Interact with the database through a sample application.
- Create MySQL tables.
- Perform queries to manage employee training and certification records.

## Objectives

- Create and configure a database server.
- Secure database access.
- Connect a web application to the database.
- Perform basic CRUD operations.

---

## Instructions

### Task 1: Create a Security Group for the Database
1. Navigate to the `VPC` section of your cloud provider's console.
2. Create a security group named `DB Security Group`:
   - Description: Permit access from default Security Group.
   - Add an inbound rule:
     - **Type:** MySQL/Aurora (3306).
     - **Source:** Default Security Group.
3. Save the security group.

---

### Task 2: Create a Database Subnet Group
1. Go to the RDS section of the console.
2. Create a subnet group named `DB Subnet Group`:
   - **Description:** DB Subnet Group.
   - **Availability Zones:** Select two different zones.
   - **Subnets:** Assign subnets from each zone.
3. Save the subnet group.

---

### Task 3: Launch the Database Instance
1. In the RDS section of the console, create a new database:
   - **Database Creation Method:** Standard create.
   - **Engine:** MySQL.
   - **Templates:** Dev/Test.
   - **Availability & Durability:** Multi-AZ DB Instance.
   - **Database Instance Identifier:** `db-practice`.
   - **Credentials:**
     - Username: `user`.
     - Password: `db-password`
   - **DB Instance Class:** Burstable classes (includes t classes).
   - **Storage Type:** General Purpose SSD (gp3).
   - **VPC:** Use your default VPC.
   - **DB subnet group:** `DB Subnet Group`.
   - **Security Group:** `DB Security Group`.
2. Wait for the database to launch.
3. Copy the database endpoint for future use.

---

### Task 4: Connect and Interact with the Database
1. Use your web application server to connect to the database:
   - Open the web application and navigate to the database configuration section.
   - Enter the following details:
     - Endpoint: (Paste the database endpoint here.)
     - Database Name: `db-practice`.
     - Username: `user`.
     - Password: `db-password`.
   - Save the settings.
2. Test the application:
   - Add, edit, and delete data.
   - Verify changes are reflected in the database.

---

### Additional Steps for Database Interaction

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
   
    ``bash
     cd ~/Downloads
     ```
   
     ```bash
     chmod 400 my_key_pair.pem
     ```
---

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

7. **Go back to `Terminal` or `Putty`:**
   - Use the PEM file to SSH into the instance:
   
     ```bash
     ssh -i my_key_pair.pem ec2-user@<public-ip-address>
     ```
   - Replace `<public-ip-address>` with the instance's public IP.

8. **Example SSH Command:**
   - For an Ubuntu instance:
   
     ```bash
     ssh -i my_key_pair.pem ubuntu@<public-ip-address>
     ```
     
   - For an Amazon Linux instance:
   
     ```bash
     ssh -i my_key_pair.pem ec2-user@<public-ip-address>
     ```

---

### 3. Install MySQL Client

- Once logged into the server, install the MySQL client:

  ```bash
  sudo apt update
  sudo apt install mysql-client
  ```

---

### 4. Set Up MySQL Tables

1. **Connect to the MySQL Database:**

   ```bash
   mysql -u db_user -p -h db_host
   ```

2. **Create `TRAINING_RECORDS` Table:**
   ```sql
   CREATE TABLE TRAINING_RECORDS (
       Employee_ID INT,
       Employee_Name VARCHAR(100),
       Training_Program VARCHAR(100),
       Training_Date DATETIME
   );
   ```

3. **Insert Sample Data into `TRAINING_RECORDS`:**

   ```sql
   INSERT INTO TRAINING_RECORDS (Employee_ID, Employee_Name, Training_Program, Training_Date) VALUES
   (101, 'Alice', 'Cloud Fundamentals', '2024-01-10 10:00:00'),
   (102, 'Bob', 'Database Basics', '2024-02-15 11:00:00'),
   (103, 'Charlie', 'Networking Essentials', '2024-03-20 12:00:00'),
   (104, 'David', 'DevOps Practices', '2024-04-25 13:00:00'),
   (105, 'Eva', 'Cybersecurity Basics', '2024-05-30 14:00:00');
   ```

4. **Verify Data in the Table:**

   ```sql
   SELECT * FROM TRAINING_RECORDS;
   ```

---

### 5. Create Certification Table

1. **Create `CERTIFICATION_DETAILS` Table:**

   ```sql
   CREATE TABLE CERTIFICATION_DETAILS (
       Employee_ID INT,
       Certification_Name VARCHAR(100),
       Certification_Date DATETIME
   );
   ```

2. **Insert Sample Data into `CERTIFICATION_DETAILS`:**

   ```sql
   INSERT INTO CERTIFICATION_DETAILS (Employee_ID, Certification_Name, Certification_Date) VALUES
   (101, 'AWS Cloud Practitioner', '2024-02-10 09:00:00'),
   (102, 'MySQL Database Admin', '2024-03-15 10:00:00'),
   (103, 'CCNA', '2024-04-20 11:00:00'),
   (104, 'Terraform Associate', '2024-05-25 12:00:00'),
   (105, 'CompTIA Security+', '2024-06-30 13:00:00');
   ```

3. **Verify Data in the Table:**

   ```sql
   SELECT * FROM CERTIFICATION_DETAILS;
   ```

---

### 6. Perform an Inner Join

1. **Query to Join Tables and Display Relevant Data:**

   ```sql
   SELECT T.Employee_ID, T.Employee_Name, C.Certification_Name, C.Certification_Date
   FROM TRAINING_RECORDS T
   INNER JOIN CERTIFICATION_DETAILS C
   ON T.Employee_ID = C.Employee_ID;
   ```

2. **Expected Output:**

   - Employee ID
   - Employee Name
   - Certification Name
   - Certification Date

---

### Notes
- Keep the PEM file private and do not share it.
- Always secure your database credentials and server configurations.
- Be mindful of potential costs incurred during this exercise.
- Charges may be incurred for this practice.

**Further Learning:**  
Visit [AWS Training](https://aws.amazon.com/training/) for more details on using AWS services effectively.
