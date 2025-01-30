
# **AWS Relational Database Operations**

This guide provides an end-to-end guide for setting up and managing relational databases on AWS. It covers the essential aspects of database operations, including creating and managing resources, querying data, using SQL functions, performing conditional searches, and altering database structures. The guide is divided into six sections, each addressing a key aspect of database management.

---

## **Introduction to the Sections**

### **Section 1: Setting Up and Performing Database Operations**
Covers the creation of AWS resources such as EC2 instances and the setup of MySQL databases. It also includes instructions for performing basic database operations like inserting, updating, deleting, and importing data.

### **Section 2: Organizing Data**
Introduces SQL clauses (`GROUP BY` and `OVER`) for grouping and analyzing data. This section focuses on aggregating data, ranking results, and calculating running totals.

### **Section 3: Selecting Data from a Database**
Explains how to use the `SELECT` statement to query data, along with database operators such as `COUNT`, `ORDER BY`, and `WHERE`. It includes examples of filtering and sorting data.

### **Section 4: Working with Functions**
Demonstrates the use of SQL functions such as `SUM`, `MIN`, `MAX`, `AVG`, `SUBSTRING_INDEX`, `LENGTH`, `TRIM`, and `DISTINCT` to process and manipulate data.

### **Section 5: Performing a Conditional Search**
Focuses on advanced filtering techniques using `WHERE`, `BETWEEN`, `LIKE`, and `LOWER` operators. This section also shows how to use aliases and SQL functions for conditional searches.

### **Section 6: Database Table Operations**
Covers essential database operations such as creating, altering, and dropping databases and tables. It includes practical examples of schema creation and modification.

---

## **Section 1: Setting Up and Performing Database Operations**

1. **Create AWS Resources:**

   - Create a VPC, EC2 instance, and configure security groups.

   - Ensure the security group allows SSH (port 22) and MySQL (port 3306) traffic through inbund rules.

2. **Install MySQL on the EC2 Instance:**

   - Connect to the EC2 instance via SSH:

     ```bash
     ssh -i <your-key-pair.pem> ec2-user@<public-ip>
     ```
     
**Replace `<your-key-pair.pem>` with your key pair directory and `<public-ip>` with your EC2 instance's public IP**

   - Update the instance and install MySQL:

     ```bash
     sudo yum update -y
     sudo yum install -y mariadb-server
     ```

   - Start the MySQL service and enable it to start on boot:

     ```bash
     sudo systemctl start mariadb
     sudo systemctl enable mariadb
     ```

   - Secure the MySQL installation:

     ```bash
     sudo mysql_secure_installation
     ```

   - Log in to MySQL as the root user:

     ```bash
     mysql -u root -p
     ```

3. **Set Up the Database:**

   - Create a database named `globe`:

     ```sql
     CREATE DATABASE globe;
     ```

   - Use the new database:

     ```sql
     USE globe;
     ```

4. **Insert, Update, and Delete Data:**

   - Create a `countries` table with the following schema:

     ```sql
     CREATE TABLE countries (
         country_id CHAR(3) PRIMARY KEY,
         name VARCHAR(50) NOT NULL,
         continent VARCHAR(30) NOT NULL,
         population INT NOT NULL,
         area FLOAT NOT NULL
     );
     ```

   - Insert sample data:

     ```sql
     INSERT INTO countries (country_id, name, continent, population, area)
     VALUES ('NZL', 'New Zealand', 'Oceania', 5000000, 268021);
     INSERT INTO countries (country_id, name, continent, population, area)
     VALUES ('CAD', 'Canada', 'North America', 38000000, 9984670);
     ```

   - Update data:

     ```sql
     UPDATE countries SET population = 5100000 WHERE country_id = 'NZL';
     ```
     
**N.B:** When `WHERE` condition is not specified, this code affects all rows.

   - Delete data:

     ```sql
     DELETE FROM countries WHERE country_id = 'CAD';
     ```

   - Verify changes:

     ```sql
     SELECT * FROM countries;
     ```

5. **Import Data:**

   - Use an SQL file `globe.sql` to bulk import data and view:

     ```bash
     scp -i <your-key-pair.pem> <~/globe.sql> ec2-user@<public-ip> #upload sql file to EC2 instance
     mysql -u root -p globe <~/globe.sql> #import the data to the EC2 instance
     mysql -u root -p
     USE globe;
     SHOW TABLES;
     SELECT * FROM countries;
     ```
     
**Replace `<your-key-pair.pem>` with your key pair directory, ´<~/globe.sql>` with path to the globe sql file (e.g., ´~/Downloads/globe.sql`), and `<public-ip>` with your EC2 instance's public IP**

---

## **Section 2: Organizing Data**

1. **Group Data Using `GROUP BY`:**

   - Aggregate total population by continent:

     ```sql
     SELECT continent, SUM(population) AS total_population
     FROM countries
     GROUP BY continent;
     ```

2. **Calculate Running Totals Using `OVER`:**

   - Display a running total of populations by continent:

     ```sql
     SELECT continent, name, population,
            SUM(population) OVER (PARTITION BY continent ORDER BY population) AS running_total
     FROM countries;
     ```

3. **Rank Records Using `RANK`:**

   - Rank countries by population (highest to lowest) within each continent:

     ```sql
     SELECT continent, name, population,
            RANK() OVER (PARTITION BY continent ORDER BY population DESC) AS 'Rank'
     FROM countries;
     ```

---

## **Section 3: Selecting Data from a Database**

1. **Query All Data:**

   ```sql
   SELECT * FROM countries;
   ```

2. **Filter Records Using `WHERE`:**

   - Retrieve countries with populations greater than 10 million:

     ```sql
     SELECT name, population FROM countries WHERE population > 10000000;
     ```

3. **Sort and Aggregate Data:**

   - Use `COUNT`, `ORDER BY`, and aliases:

     ```sql
     SELECT name, continent, population AS "Population Count"
     FROM countries
     ORDER BY population DESC;
     ```
     
**N.B:** The ORDER BY option orders data in ascending order so `DESC` needs to be specified.

---

## **Section 4: Working with Functions**

1. **Aggregate Functions:**

   - Calculate population statistics:

     ```sql
     SELECT SUM(population), AVG(population), MAX(population), MIN(population)
     FROM countries;
     ```

2. **String Manipulation Functions:**

   - Extract the first word from the continent name:

     ```sql
     SELECT continent, SUBSTRING_INDEX(continent, ' ', 1) AS first_word
     FROM countries;
     ```

3. **Filter Duplicates Using `DISTINCT`:**

   ```sql
   SELECT DISTINCT(continent) FROM countries WHERE population > 10000000;
   ```
4. **Find Regions with Names Fewer Than 10 Characters using LENGTH() and TRIM() to determine the length of trimmed strings:**

   ```sql
   SELECT continent
   FROM countries
   WHERE LENGTH(TRIM(continent)) < 10;
   ```

5. **Split Region Names into Two Columns:**

   ```sql
   SELECT 
       name,
       SUBSTRING_INDEX(continent, '/', 1) AS "Continent Name 1",
       SUBSTRING_INDEX(continent, '/', -1) AS "Continent Name 2"
   FROM countries
   WHERE Region = 'Oceania/Europe';
   ```

---

## **Section 5: Performing a Conditional Search**

1. **Filter Using `BETWEEN`:**

   - Retrieve countries with populations between 5 and 50 million, both codes below works the same:

     ```sql
     SELECT name, population FROM countries WHERE population BETWEEN 5000000 AND 50000000;
     ```
     
     ```sql
     SELECT name, population FROM countries WHERE population >= 5000000 AND population <= 50000000;
     ```
    
2. **Search for Patterns with `LIKE`:**

   - Find continents containing "America":

     ```sql
     SELECT name, continent AS "American Countries" FROM countries WHERE continent LIKE '%America%';
     ```

3. **Case-Sensitive Searches:**

   - Convert strings to lowercase using `LOWER` as SQL is not a case-sensitive language. You can use either SELECT or select when writing a query. However, databases that you query might be configured with a case-sensitive collation. If the database was case sensitive, you would not be able to query a column named Population by using `select population from countries`

     ```sql
     SELECT name, continent AS "American Countries" FROM countries WHERE LOWER(continent) LIKE '%america%';
     ```
     
4. **Specific Case Search:**

     ```sql
     SELECT 
         SUM(area) AS "Total Surface Area",
         SUM(population) AS "Total Population"
     FROM countries
     WHERE continent = 'Oceania';
     ```

---

## **Section 6: Database Table Operations**

1. **Alter a Table:**

   - Rename a column in the `countries` table:

     ```sql
     ALTER TABLE countries RENAME COLUMN area TO land_area;
     SHOW COLUMNS FROM countries;
     ```

2. **Drop Tables and Databases:**

   - Delete the `countries` table:

     ```sql
     DROP TABLE countries;
     ```

   - Delete the `globe` database:

     ```sql
     DROP DATABASE globe;
     ```
     
   - Exit MySQL:

     ```sql
     EXIT;
     ```
---

## **Notes and Troubleshooting Tips**

### **General Tips**

1. **Verify Connection Settings:**
   - Ensure your EC2 instance's security group allows inbound traffic on port 3306 for MySQL.
   - Confirm your SSH key and public IP address are correct.
   
2. **When using sudo, the system expects the password of the user account you are currently logged in as.**

3. **Validate SQL Syntax:**
   - Always check for syntax errors in SQL commands, especially when creating tables or inserting data.

4. **Check Permissions:**
   - Ensure the MySQL user has the necessary privileges to create databases, tables, and insert data.

5. **Backup Your Data:**
   - Before performing `DROP` or `DELETE` operations, back up your database to prevent accidental data loss.

### **Troubleshooting MySQL Issues**

1. **MySQL Service Not Starting:**
   - Run the following commands to check and restart MySQL:
   
     ```bash
     sudo systemctl status mariadb
     sudo systemctl restart mariadb
     ```

2. **Cannot Connect to MySQL:**
   - Ensure the MySQL service is running.
   - Verify that your MySQL user credentials (e.g., `root` and password) are correct.

3. **Import Errors:**
   - If importing an SQL file fails, verify that the file is in the correct format and contains valid SQL statements.

4. **Table Not Found Errors:**
   - Use the `USE` command to switch to the correct database:
   
     ```sql
     USE globe;
     ```

5. **Duplicate Key Errors:**
   - If inserting data results in a duplicate key error, verify that your primary key values are unique.

### **Additional Resources**

- MySQL Documentation: https://dev.mysql.com/doc/

- AWS Training and Certification: https://aws.amazon.com/training/

- Troubleshooting AWS EC2 Instances: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/TroubleshootingInstances.html


