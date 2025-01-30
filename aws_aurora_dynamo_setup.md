# **Setting Up Amazon Aurora and Amazon DynamoDB**

## **Objectives**

- Set up an **Amazon Aurora** MySQL-compatible database.
- Connected an **EC2 instance** to Aurora and executed SQL queries.
- Created and managed an **Amazon DynamoDB** table.
- Inserted, queried, modified, and deleted data in DynamoDB.

## **Section 1: Amazon Aurora Setup**

Amazon Aurora is a fully managed relational database engine that is MySQL-compatible. This section will how to set up an Aurora instance, configuring an EC2 instance to connect to the database, and performing basic SQL operations.

### Step 1: Create a VPC and Subnet Group
1. Navigate to the **VPC** service in AWS.
2. Create a new VPC named **DatabaseVPC** with CIDR block `10.0.0.0/16`.
3. Create two subnets within **DatabaseVPC** (one in each Availability Zone).
4. Create a **DBSubnetGroup**:
   - Go to the **RDS** service.
   - Click on **Subnet Groups** in the left menu.
   - Click **Create DB Subnet Group**.
   - Enter **Name** as `DBSubnetGroup` and select **DatabaseVPC`.
   - Select both created subnets and click **Create**.

### Step 2: Create a Security Group for Aurora
1. Go to the **EC2 Security Groups** page.
2. Create a new security group named **AuroraSecurityGroup**.
3. Add an inbound rule to allow MySQL/Aurora traffic (`3306`) from your EC2 instance security group.

### Step 3: Create an Aurora Instance
1. Navigate to **RDS** and click **Create database**.
2. Select **Aurora (MySQL Compatible)** as the engine.
3. Choose **Standard create** and use the default major version.
4. Set up the following configurations:
   - **DB cluster identifier**: `MyAuroraDB`
   - **Master username**: `dbadmin`
   - **Master password**: `securepassword123`
5. Under **Connectivity**:
   - Select **DatabaseVPC**.
   - Choose **DBSubnetGroup** created earlier.
   - Set **Public access** to **No**.
   - Select **AuroraSecurityGroup**.
6. Disable **Multi-AZ deployment** for simplicity.
7. Click **Create database**.

### Step 4: Launch an EC2 Instance for Database Access
1. Go to **EC2** and click **Launch Instance**.
2. Choose **Amazon Linux 2** as the AMI.
3. Select **t3.micro** instance type.
4. Under **Networking**:
   - Place it in **DatabaseVPC**.
   - Assign a public IP.
   - Use a new security group **EC2SecurityGroup** allowing SSH and outbound MySQL traffic.
5. Connect to the instance using SSH once launched.

### Step 5: Configure the EC2 Instance for Database Access
1. Install the MySQL client on the EC2 instance:

   ```bash
   sudo yum install mariadb -y
   ```
   
2. Obtain the **writer endpoint** from the Aurora instance.
3. Connect to the Aurora database:

   ```bash
   mysql -u dbadmin -p -h <aurora-endpoint>
   ```

### Step 6: Create and Query a Database Table
1. Create a database:

   ```sql
   CREATE DATABASE LibraryDB;
   USE LibraryDB;
   ```
   
2. Create a table:

   ```sql
   CREATE TABLE Books (
       BookID CHAR(5) PRIMARY KEY,
       Title VARCHAR(255) NOT NULL,
       Author VARCHAR(100) NOT NULL,
       PublishedYear INT,
       Genre VARCHAR(50)
   );
   ```
   
3. Insert 50 sample records:

   ```sql
   INSERT INTO Books VALUES 
   ('B002', 'To Kill a Mockingbird', 'Harper Lee', 1960, 'Fiction'),
   ('B003', '1984', 'George Orwell', 1949, 'Dystopian'),
   ('B004', 'Pride and Prejudice', 'Jane Austen', 1813, 'Romance'),
   ('B005', 'The Catcher in the Rye', 'J.D. Salinger', 1951, 'Fiction'),
   ('B006', 'Moby Dick', 'Herman Melville', 1851, 'Adventure'),
   ('B007', 'Brave New World', 'Aldous Huxley', 1932, 'Dystopian'),
   ('B008', 'War and Peace', 'Leo Tolstoy', 1869, 'Historical Fiction'),
   ('B009', 'The Odyssey', 'Homer', -800, 'Epic Poetry'),
   ('B051', 'The Hobbit', 'J.R.R. Tolkien', 1937, 'Fantasy');
   ```
   
4. Query the table:

   ```sql
   SELECT * FROM Books WHERE PublishedYear > 1950;
   ```

## **Section 2: Amazon DynamoDB Setup**

Amazon DynamoDB is a fast NoSQL database service. This section covers how to create, populate, query, and delete a DynamoDB table.

### Step 1: Create a DynamoDB Table
1. Navigate to **DynamoDB**.
2. Click **Create table**.
3. Enter the following details:
   - **Table name**: `MusicLibrary`
   - **Partition key**: `Artist` (String)
   - **Sort key**: `Song` (String)
4. Use default settings and create the table.

### Step 2: Insert Data into the Table
1. Select the **MusicLibrary** table.
2. Click **Create item**.
3. Insert the following 10 records:

   ```
   Artist: Queen, Song: Bohemian Rhapsody, Album: A Night at the Opera, Year: 1975
   Artist: Nirvana, Song: Smells Like Teen Spirit, Album: Nevermind, Year: 1991
   Artist: The Beatles, Song: Hey Jude, Album: Hey Jude, Year: 1968
   Artist: Michael Jackson, Song: Thriller, Album: Thriller, Year: 1982
   Artist: Madonna, Song: Like a Virgin, Album: Like a Virgin, Year: 1984
   Artist: The Rolling Stones, Song: Paint It Black, Album: Aftermath, Year: 1966
   Artist: Elvis Presley, Song: Jailhouse Rock, Album: Jailhouse Rock, Year: 1957
   Artist: Bob Dylan, Song: Like a Rolling Stone, Album: Highway 61 Revisited, Year: 1965
   Artist: Led Zeppelin, Song: Stairway to Heaven, Album: Led Zeppelin IV, Year: 1971
   Artist: Taylor Swift, Song: Shake It Off, Album: 1989, Year: 2014
   ```

### Step 3: Query the Table
1. Click Explore Items > Query.
2. Set Partition Key as Adele and Sort Key as Hello.
3. Click Run.

### Step 4: Modify an Item

1. In Explore Items, locate Ed Sheeran - Shape of You.
2. Change the Year from 2017 to 2018.
3. Click Save changes.

### Step 5: Delete the Table

1. Select MusicLibrary in the Tables list.
2. Click Actions > Delete table.
3. Confirm deletion.

---

