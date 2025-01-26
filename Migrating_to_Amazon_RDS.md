# Migrating to Amazon RDS From MariaDB Database

## Overview
This guide provides a comprehensive process to create necessary resources for deploying and using an Amazon RDS MariaDB instance. It includes instructions for setting up the required infrastructure, migrating data from a MariaDB database on an EC2 instance, and monitoring the database.

## Objectives

1. Create and configure AWS resources for Amazon RDS MariaDB.
2. Deploy an Amazon RDS MariaDB instance.
3. Migrate data from a MariaDB database on an EC2 instance to Amazon RDS.
4. Monitor the Amazon RDS instance using Amazon CloudWatch metrics.

## Prerequisites
- An active AWS account.
- Basic understanding of AWS services like EC2, RDS, and CLI commands.
- A MariaDB database running on an EC2 instance with data to migrate.

---

## Steps

### 1. Create Necessary AWS Resources

#### 1.1 Configure the AWS CLI

1. Install the AWS CLI on your local machine.
2. Run `aws configure` and provide the following:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region
   - Default output format (`json`).

#### 1.2 Set Up a VPC

1. **Create a VPC**:

   ```bash
   aws ec2 create-vpc 
   --cidr-block 10.200.0.0/16 
   --tag-specifications \
   'ResourceType=vpc,Tags=[{Key=Name,Value=CafeVPC}]'
   ```
   
   - Record the VPC ID from the command output.

2. **Create Subnets**:
   - Create two private subnets in different Availability Zones. Replace `<AZ1>` & `<AZ1>` with your preferred Availability zone. 
   
     ```bash
     aws ec2 create-subnet 
     --vpc-id <VPC ID> 
     --cidr-block 10.200.1.0/24 
     --availability-zone <AZ1>
     aws ec2 create-subnet 
     --vpc-id <VPC ID> 
     --cidr-block 10.200.2.0/24 
     --availability-zone <AZ2>
     ```
     
   - Record the Subnet IDs for later use.

#### 1.3 Create a Security Group

1. **Create Security Group**:
   - Create a security group for the RDS instance:
   
     ```bash
     aws ec2 create-security-group \
     --group-name CafeDatabaseSG \
     --description "Security group for Cafe database" \
     --vpc-id <VPC ID>
     ```
     
   - Record the Security Group ID.

2. **Add Inbound Rule**:
   - Allow MySQL access:
   
     ```bash
     aws ec2 authorize-security-group-ingress \
     --group-id <Security Group ID> \
     --protocol tcp --port 3306 \
     --cidr 0.0.0.0/0
     ```

#### 1.4 Create a Subnet Group

1. **Set Up Subnet Group**:
   - Use the private subnets created earlier. Replace `<Subnet ID 1>` & `<Subnet ID 2>` with the subnet ID recorded earlier in 1.2
   
     ```bash
     aws rds create-db-subnet-group \
     --db-subnet-group-name CafeDBSubnetGroup \
     --db-subnet-group-description "Subnet group for Cafe database" \
     --subnet-ids <Subnet ID 1> <Subnet ID 2>
     ```

### 2. Deploy Amazon RDS MariaDB Instance

#### 2.1 Create the RDS Instance

1. **Run the RDS Command**, remember to replace `<Security Group ID>` with the ID recorded earlier in 1.3:

   ```bash
   aws rds create-db-instance \
   --db-instance-identifier CafeDBInstance \
   --engine mariadb \
   --engine-version 10.5.13 \
   --db-instance-class db.t3.micro \
   --allocated-storage 20 \
   --db-subnet-group-name CafeDBSubnetGroup \
   --vpc-security-group-ids <Security Group ID> \
   --no-publicly-accessible \
   --master-username admin \
   --master-user-password 'SecurePass123!'
   ```

2. **Monitor Instance Status**:
   - Check the status until it displays `available`:
   
     ```bash
     aws rds describe-db-instances \
     --db-instance-identifier CafeDBInstance \
     --query "DBInstances[*].[Endpoint.Address,DBInstanceStatus]"
     ```
     
   - Record the endpoint address.

### 2.2. **Simulate and Migrate Data to Amazon RDS**

#### Simulate the Database on EC2

Since we don't have an existing database, we will simulate one by creating a sample database with test data on our EC2 instance.

- Install MariaDB:Log in to your EC2 instance and install MariaDB

     ```bash
     sudo yum install mariadb-server -y
     sudo systemctl start mariadb
     sudo systemctl enable mariadb
     ```

- Create a Sample Database: Use the MariaDB client to create a database and populate it with test data:

     ```bash
     mysql -u root
     ```

- Run the following SQL commands in the MariaDB client:

     ```sql
     CREATE DATABASE cafe_db;

     USE cafe_db;

     CREATE TABLE products (
         id INT AUTO_INCREMENT PRIMARY KEY,
         name VARCHAR(100),
         price DECIMAL(10, 2)
     );

     INSERT INTO products (name, price) VALUES 
     ('Coffee', 2.99),
     ('Tea', 1.99),
     ('Knekkebrod', 15.99),
     ('Cake', 12.05),
     ('Brownie', 25.99),
     ('Cafe Latte', 55.99),
     ('Croissant', 20.99),
     ('Biscuit', 14.99),
     ('Bread', 12.99),
     ('Muffin', 3.49);

     SELECT * FROM products;
     ```

- Exit the MariaDB client:

     ```sql
     EXIT;
     ```

Once you have simulated the database, proceed to back it up as described in the next section.

### 3. Migrate Data from EC2 to Amazon RDS

#### 3.1 Backup the EC2 MariaDB Database

1. **Connect to the EC2 Instance**:
   - Use EC2 Instance Connect or SSH to access the EC2 instance hosting the MariaDB database.

2. **Create a Backup**:
   - Use `mysqldump` to back up the database:
   
     ```bash
     mysqldump 
     --user=admin 
     --password='SecurePass123' 
     --databases cafe_db > cafedb-backup.sql
     ```

#### 3.2 Restore the Backup to Amazon RDS

1. **Transfer the Backup File**:
   - Use SCP or any file transfer method to copy `cafedb-backup.sql` to your local machine.

2. **Restore the Backup**:
   - Use the MySQL client to restore the database to the RDS instance, **remember to replace `<RDS Endpoint Address>` with the correct endpoint address copied earlier in step 2.1 while monitoring the instance status.**
   
     ```bash
     mysql 
     --host=<RDS Endpoint Address> 
     --user=admin 
     --password='SecurePass123!' < cafedb-backup.sql
     ```

#### 3.3 Verify Data Migration

1. **Connect to the RDS Database, remember to replace `<RDS Endpoint Address>` with the correct endpoint address copied earlier in step 2.1 while monitoring the instance status.**

   ```bash
   mysql 
   --host=<RDS Endpoint Address> 
   --user=admin 
   --password='SecurePass123!' cafe_db
   ```

2. **Verify the Data**:
   - Query the tables to ensure the data is intact:
   
     ```sql
     SELECT * FROM products;
     ```

### 4. Monitor the Amazon RDS Instance

#### 4.1 Access Monitoring Metrics

1. **Use CloudWatch**:
   - Navigate to the RDS console and select your database instance.
   - View metrics like CPU utilization, database connections, and disk space usage under the `Monitoring` tab.

2. **Simulate Load** by running SQL queries to create activity and observe metrics changes.

   - Open a MySQL session through SSH or instance connect and interact with the database, **remember to replace `<RDS Endpoint Address>` with the correct endpoint address copied earlier in step 2.1 while monitoring the instance status.**

     ```bash
     mysql 
     --host=<RDS Endpoint Address> 
     --user=admin 
     --password='SecurePass123!' cafe_db
     ```

   - Example SQL queries:

     ```sql
     SELECT * FROM products;
     INSERT INTO products (name, price) VALUES ('Latte', 3.99);
     DELETE FROM products WHERE name='Tea';


   - **Observe Metrics:** Use the RDS console to observe changes in metrics such as `DatabaseConnections` and `CPUUtilization` based on the simulated queries.
   
---

## **References**
- AWS CLI Documentation for RDS

- Amazon RDS Monitoring Metrics Overview
