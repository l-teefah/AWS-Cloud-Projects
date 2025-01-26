
# AWS Lambda Challenge: Student Attendance Tracker

## Overview
In this tutorial, you will deploy and configure an AWS Lambda-based serverless computing solution. The Lambda function retrieves student attendance data from a database and emails a daily attendance report to the school administrator. The database connection information is stored in AWS Systems Manager Parameter Store, and the database itself runs on an Amazon EC2 instance with a Linux, Apache, MySQL, and PHP (LAMP) stack.

---

## Objectives
By completing this exercise, you will:
1. Recognize the necessary IAM policy permissions to enable a Lambda function to access other AWS resources.
2. Create a Lambda layer to execute an external library dependency.
3. Create Lambda functions to extract data from a database and send reports to users.
4. Deploy and test a Lambda function that is initiated based on a schedule and that invokes another function.
5. Use CloudWatch logs to troubleshoot any issues with the Lambda function.

---

## Prerequisites
- Access to the AWS Management Console.
- Basic knowledge of Python and AWS services such as Lambda, S3, SNS, and Systems Manager Parameter Store.
-  Two IAM roles with different policies attached.
- **Downloadable Files**
  1. **PyMySQL Library**: [pymysql-v3.zip](pymysql-v3.zip)
  2. **Data Extractor Function**: [studentAttendanceDataExtractor-v1.zip](studentAttendanceDataExtractor-v1.zip)
- VPC, Subnet, and Security Group Configuration.

---

## **Setting IAM Role Settings**

- **Analyze Roles for Permissions**:
   - Ensure the `studentAttendanceReportRole` has policies for **AmazonSNSFullAccess**, **AWSLambdaBasicRunRole**, **AWSLambdaRole** and **AmazonSSMReadOnlyAccess**.
   - Ensure the `studentAttendanceReportDERole` has policies for **AWSLambdaBasicRunRole** and **AWSLambdaVPCAccessRunRole**.
   
---

## **VPC, Subnet, and Security Group Configuration**

## **Step 1: VPC Configuration**
1. **Locate Your VPC**:
   - Open the AWS Management Console and navigate to **VPC**.
   - Identify the VPC where your Lambda function and database will reside (e.g., the `default VPC` if using default).

2. **Ensure Subnets Are Configured**:
   - Confirm that your VPC has private subnets. If not, create a **private subnet** for the database.


## **Step 2: Subnet Assignment**
- Assign the **same subnet** or **different private subnets** within the same VPC to both Lambda and the database.
- Ensure the subnets belong to the same Availability Zone for low latency (recommended but not mandatory).


## **Step 3: Security Group Configuration**
AWS Security Groups act as virtual firewalls to control traffic. You need two security groups:

### **1. Database Security Group**
This security group is attached to the MySQL EC2 instance.

- **Inbound Rule**:
  - **Type**: MySQL/Aurora
  - **Protocol**: TCP
  - **Port Range**: 3306 (default MySQL port)
  - **Source**: Security group of the Lambda function.

- **Outbound Rule**:
  - Allow **All Traffic** (default) or restrict to specific Lambda’s private IP range.

### **2. Lambda Security Group**
This security group is attached to the Lambda function.

- **Inbound Rule**:
  - Not required (Lambda does not receive traffic).

- **Outbound Rule**:
  - **Type**: Custom TCP
  - **Protocol**: TCP
  - **Port Range**: 3306
  - **Destination**: Database Security Group.


## **Step 4: Creating the Database Instance**

1. **Launch an EC2 Instance**:
   - Navigate to the **EC2 Dashboard** in the AWS Management Console.
   - Click **Launch Instances**.

2. **Configure Instance Details**:
   - **AMI**: Choose an Amazon Linux 2 AMI or another preferred Linux distribution.
   - **Instance Type**: Choose `t3.micro` (free tier eligible) or another type based on your requirements.
   - **VPC**: Select the VPC where the Lambda function resides.
   - **Subnet**: Select the private subnet configured earlier.
   - **Auto-assign Public IP**: Disable (for private subnet use).

3. **Configure Storage**:
   - Add storage as needed (e.g., 8GB default).

4. **Add Tags**:
   - Add a tag for identification, e.g., `Key: Name, Value: StudentAttendanceDatabase`.

5. **Configure Security Group**:
   - Attach the **Database Security Group** created earlier.

6. **Launch and Connect**:
   - Launch the instance.
   - Use SSH to connect to the instance and install the MySQL server:
   
     ```bash
     sudo yum update -y
     sudo yum install mysql-server -y
     sudo systemctl start mysqld
     sudo systemctl enable mysqld
     ```

7. **Configure MySQL**:
   - Secure the MySQL installation:
   
     ```bash
     sudo mysql_secure_installation
     ```
     
   - Create the database and table for the lab:
   
     ```sql
     CREATE DATABASE student_attendance;
     USE student_attendance;
     CREATE TABLE attendance (
         student_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
         student_name VARCHAR(100) NOT NULL,
         attendance_status VARCHAR(10) NOT NULL,
         date DATE NOT NULL
     );

     INSERT INTO attendance (student_name, attendance_status, date)
     VALUES 
     ('Alice Smith', 'Present', CURDATE()),
     ('Bob Johnson', 'Absent', CURDATE()),
     ('Charlie Brown', 'Present', CURDATE()),
     ('David Thompson', 'Present', CURDATE()),
     ('Emily Davis', 'Absent', CURDATE()),
     ('Franklin Richards', 'Present', CURDATE()),
     ('Grace Hopper', 'Absent', CURDATE()),
     ('Henry Ford', 'Present', CURDATE()),
     ('Isabelle Turner', 'Absent', CURDATE()),
     ('Jack Ryan', 'Present', CURDATE()),
     ('Karen Smith', 'Absent', CURDATE()),
     ('Louis Pasteur', 'Present', CURDATE()),
     ('Mary Curie', 'Absent', CURDATE()),
     ('Neil Armstrong', 'Present', CURDATE()),
     ('Oscar Wilde', 'Absent', CURDATE()),
     ('Paul Atreides', 'Present', CURDATE()),
     ('Queen Elizabeth', 'Absent', CURDATE()),
     ('Ron Weasley', 'Present', CURDATE()),
     ('Sophia Loren', 'Absent', CURDATE()),
     ('Thomas Edison', 'Present', CURDATE()),
     ('Uma Thurman', 'Absent', CURDATE()),
     ('Victor Hugo', 'Present', CURDATE()),
     ('William Shakespeare', 'Absent', CURDATE()),
     ('Xavier Woods', 'Present', CURDATE()),
     ('Yara Shahidi', 'Absent', CURDATE()),
     ('Zane Grey', 'Present', CURDATE()),
     ('Luna Lovegood', 'Absent', CURDATE()),
     ('Bruce Wayne', 'Present', CURDATE()),
     ('Clark Kent', 'Absent', CURDATE()),
     ('Diana Prince', 'Present', CURDATE()),
     ('Barry Allen', 'Absent', CURDATE()),
     ('Hal Jordan', 'Present', CURDATE()),
     ('Arthur Curry', 'Absent', CURDATE()),
     ('Victor Stone', 'Present', CURDATE()),
     ('Dinah Lance', 'Absent', CURDATE()),
     ('John Constantine', 'Present', CURDATE()),
     ('Oliver Queen', 'Absent', CURDATE()),
     ('Eobard Thawne', 'Present', CURDATE()),
     ('Leonard Snart', 'Absent', CURDATE()),
     ('Mick Rory', 'Present', CURDATE()),
     ('Sara Lance', 'Absent', CURDATE()),
     ('Ray Palmer', 'Present', CURDATE()),
     ('Martin Stein', 'Absent', CURDATE()),
     ('Jefferson Jackson', 'Present', CURDATE()),
     ('Rip Hunter', 'Absent', CURDATE()),
     ('Nathaniel Heywood', 'Present', CURDATE()),
     ('Amaya Jiwe', 'Absent', CURDATE()),
     ('Zari Tomaz', 'Present', CURDATE()),
     ('Ava Sharpe', 'Absent', CURDATE()),
     ('Charlie', 'Present', CURDATE()),
     ('Gary Green', 'Absent', CURDATE()),
     ('Mona Wu', 'Present', CURDATE()),
     ('Nora Darhk', 'Absent', CURDATE()),
     ('Behrad Tarazi', 'Present', CURDATE()),
     ('Astra Logue', 'Absent', CURDATE()),
     ('Spooner Cruz', 'Present', CURDATE()),
     ('Esperanza Cruz', 'Absent', CURDATE()),
     ('Michael Holt', 'Present', CURDATE()),
     ('Ted Grant', 'Absent', CURDATE()),
     ('Helena Bertinelli', 'Present', CURDATE()),
     ('Huntress', 'Absent', CURDATE()),
     ('Rene Ramirez', 'Present', CURDATE()),
     ('Curtis Holt', 'Absent', CURDATE()),
     ('Adrian Chase', 'Present', CURDATE()),
     ('Talia al Ghul', 'Absent', CURDATE()),
     ('Nyssa al Ghul', 'Present', CURDATE()),
     ('Malcolm Merlyn', 'Absent', CURDATE()),
     ('Slade Wilson', 'Present', CURDATE()),
     ('Ra’s al Ghul', 'Absent', CURDATE()),
     ('Tommy Merlyn', 'Present', CURDATE()),
     ('Moira Queen', 'Absent', CURDATE()),
     ('Robert Queen', 'Present', CURDATE()),
     ('Walter Steele', 'Absent', CURDATE
     ```


## **Step 5: Creating and Configuring the Lambda Function**

1. **Create the Lambda Function**:
   - Open the AWS Management Console and navigate to **Lambda**.
   - Click **Create Function**.
   - Choose **Author from scratch** and configure the following options:
     - **Function name**: `studentAttendanceDataExtractor`
     - **Runtime**: Python 3.9
     - **Role**: `studentAttendanceReportDERole`

2. **Attach VPC Configuration to Lambda**:
   - Under the **Configuration** tab, choose **VPC**.
   - Click **Edit** and configure the following:
     - **VPC**: Select your VPC.
     - **Subnets**: Choose the private subnet containing the database.
     - **Security Groups**: Choose the Lambda security group.

3. **Upload Code to Lambda**:
   - Write or upload the function code to connect to the database and retrieve attendance data.

---

## Tutorial Steps

### Step 1: Create a Lambda Layer

1. **Navigate to AWS Lambda**:
   - Open the AWS Management Console and go to the Lambda service.
   - Select **Layers** > **Create Layer**.

2. **Upload the Layer**:
   - Name: `pymysqlLibrary`
   - Description: PyMySQL library modules
   - Upload `pymysql-v3.zip` downloaded earlier as the package.
   - Compatible Runtimes: Python 3.9
   - Click **Create**.

---

### Step 2: Create the Data Extractor Lambda Function

#### Code for `studentAttendanceDataExtractor`

```python
import boto3
import pymysql
import sys

def lambda_handler(event, context):
    # Retrieve database connection parameters from event
    db_url = event['dbUrl']
    db_name = event['dbName']
    db_user = event['dbUser']
    db_password = event['dbPassword']

    try:
        # Establish database connection
        conn = pymysql.connect(
            host=db_url,
            user=db_user,
            passwd=db_password,
            db=db_name,
            cursorclass=pymysql.cursors.DictCursor
        )
    except pymysql.Error as e:
        print("ERROR: Could not connect to database.")
        print(f"Error Details: {e}")
        sys.exit()

    # Execute query to fetch attendance data
    with conn.cursor() as cur:
        cur.execute("SELECT student_id, student_name, attendance_status FROM attendance")
        result = cur.fetchall()

    conn.close()

    return {'statusCode': 200, 'body': result}
```

1. **Create the Function**:
   - Name: `studentAttendanceDataExtractor`
   - Runtime: Python 3.9
   - Role: Use `studentAttendanceReportDERole`.

2. **Add the Lambda Layer**:
   - In the function configuration, attach the `pymysqlLibrary` layer.

3. **Upload the Function Code**:
   - Update the handler to `studentAttendanceDataExtractor.lambda_handler`.
   - Upload the `studentAttendanceDataExtractor-v1.zip` file downloaded earlier.

4. **Configure VPC Settings**:
   - Assign default VPC, subnet, and security group for database access. 

5. **Test the Function**:
   - Use Parameter Store values for database connection parameters.
   - Verify that the function returns attendance data from the database.

---

### Step 3: Configure Notifications

1. **Create an SNS Topic**:
   - Name: `studentAttendanceReportTopic`
   - Subscribe an email address and confirm the subscription.

---

### Step 4: Create the Main Report Lambda Function

#### Code for `studentAttendanceReport`

```python
import boto3
import json

def lambda_handler(event, context):
    sns = boto3.client('sns')
    lambda_client = boto3.client('lambda')

    # Database connection parameters from Parameter Store
    db_params = {
        "dbUrl": "<parameter-store-db-url>",
        "dbName": "<parameter-store-db-name>",
        "dbUser": "<parameter-store-db-user>",
        "dbPassword": "<parameter-store-db-password>"
    }

    # Invoke Data Extractor Lambda
    response = lambda_client.invoke(
        FunctionName='studentAttendanceDataExtractor',
        InvocationType='RequestResponse',
        Payload=json.dumps(db_params)
    )

    attendance_data = json.loads(response['Payload'].read())['body']

    # Format the report
    report = "Daily Attendance Report:
"
    for record in attendance_data:
        report += f"{record['student_id']} - {record['student_name']} - {record['attendance_status']}
"

    # Send report via SNS
    sns.publish(
        TopicArn=event['topicARN'],
        Subject='Daily Attendance Report',
        Message=report
    )

    return {
        "statusCode": 200,
        "body": "Attendance Report Sent."
    }
```

1. **Create the Function**:
   - Name: `studentAttendanceReport`
   - Runtime: Python 3.9
   - Role: Use `studentAttendanceReportRole`.

2. **Set Environment Variables**:
   - Add an environment variable `topicARN` with the ARN of the SNS topic.

3. **Test the Function**:
   - Ensure the function sends an email with the attendance report.

---

### Step 5: Schedule the Report Generation

1. **Add a Trigger**:
   - Use EventBridge (CloudWatch Events) to trigger the function every weekday at 7 PM.
   - Example Cron Expression: `cron(0 19 ? * MON-FRI *)`
     - `0`: Trigger at 0 minutes past the hour.
     - `19`: Trigger at 7 PM UTC.
     - `?`: No specific day of the month.
     - `*`: Every month.
     - `MON-FRI`: Only Monday through Friday.

---

## **Additional Resources**
- [Using AWS Lambda with Scheduled Events](https://docs.aws.amazon.com/lambda/latest/dg/with-scheduled-events.html)

- [Accessing CloudWatch Logs for AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html)

---

