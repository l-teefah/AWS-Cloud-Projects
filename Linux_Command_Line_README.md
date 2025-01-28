# **Linux Command Line Lab**

## Overview
This guide outlines the steps to connect to a Linux server via SSH, run system and session commands, work with commands like `tee`, `sort`, `cut`, and `sed`, edit files using Vim and nano, and optimize workflows using pipes and bash history. 

---

## **Set Up and Connect to an EC2 Instance**

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
2. Navigate to the directory containing the `.pem` file and edit `/path/to/downloaded/file` with the path to the key pair file:

   ```bash
   cd /path/to/downloaded/keypairfile
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

## SECTION 1: Run Basic Linux Commands

Once connected to the EC2 instance, execute the following commands to gather system information:

1. **Find the current user:**

   ```bash
   whoami
   ```

2. **Display the hostname:**

   ```bash
   hostname -s
   ```

3. **Check system uptime:**

   ```bash
   uptime -p
   ```

4. **View user and session details:**

   ```bash
   who -H -a
   ```

5. **Check date and time in different time zones:**

   ```bash
   TZ=America/New_York date
   TZ=America/Los_Angeles date
   ```

6. **View calendar with Julian dates:**

   ```bash
   cal -j
   ```

7. **Alternate calendar views:**

   ```bash
   cal -s   # Sunday to Saturday
   cal -m   # Monday to Sunday
   ```

8. **View user ID and group information:**

   ```bash
   id ec2-user
   ```

---

## SECTION 2: Working with Commands

### Step 1: Use the `tee` Command
The `tee` command displays output to the screen and writes it to a file simultaneously.
1. Confirm you are in the `/home/ec2-user` directory:

   ```bash
   pwd
   ```
   
2. Use the `tee` command to capture the hostname:

   ```bash
   hostname | tee output.txt
   ```
   
3. Verify the file was created:

   ```bash
   ls
   ```

### Step 2: Use the `sort` Command
The `sort` command reorders file content.
1. Create a `test.csv` file:

   ```bash
   cat > test.csv
   Factory, 1, Paris
   Store, 2, Dubai
   Factory, 3, Brasilia
   Store, 4, Algiers
   Factory, 5, Tokyo
   ```
   
   - Press `CTRL+D` to save the file.
   
2. Sort the contents:

   ```bash
   sort test.csv
   ```
   
3. Search for specific content using a pipe:

   ```bash
   grep Paris test.csv
   ```

### Step 3: Use the `cut` Command
The `cut` command extracts specific fields from a file.
1. Create a `city.csv` file:

   ```bash
   cat > city.csv
   Stavanger, Norway
   Ibadan, Nigeria
   Johannesburg, South Africa
   Kaunas, Lithuania
   Greensboro, North California
   ```
   
   - Press `CTRL+D` to save the file.
   
2. Extract city names:

   ```bash
   cut -d ',' -f 1 city.csv
   ```

### Step 4: Use the `sed` Command
The `sed` command modifies text in a file.
1. Replace commas with periods in `city.csv` and `test.csv`:

   ```bash
   sed 's/,/./' city.csv
   sed 's/,/./' test.csv
   ```

---

## SECTION 3: Editing Files

### Step 1: Learn Vim with Vimtutor
1. Start the Vim tutorial:

   ```bash
   vimtutor
   ```
   
2. Follow lessons 1-4 in Vimtutor to practice basic Vim commands.
3. Exit Vim tutor:

   ```bash
   :q!
   ```

### Step 2: Edit Files with Vim
1. Create a new file using Vim:

   ```bash
   vim helloworld
   ```
   
2. Enter insert mode (`i`) and type the following:

   ```text
   Hello World!
   This is my first file in Linux and I am editing it in Vim!
   ```
   
3. Exit insert mode (press `ESC`) and save the file:

   ```bash
   :wq
   ```
   
4. Reopen the file to make edits:

   ```bash
   vim helloworld
   ```
   
5. Add another line, save, and exit.

### Step 3: Edit Files with Nano
1. Create and open a file using Nano:

   ```bash
   nano cloudworld
   ```
   
2. Type the following text directly:

   ```text
   I am using nano this time! There is no need for insert mode, just type away!!.
   ```
   
3. Save changes (CTRL+O) and exit Nano (CTRL+X).

---

## Task 5: Optimize Workflow Using Bash History

### Step 1: View Command History
- Display previously executed commands:

  ```bash
  history
  ```

### Step 2: Search Command History
- Press `CTRL+R` and type a keyword (e.g., `tee`) to search for related commands.

### Step 3: Repeat the Last Command
- Use `!!` to rerun the most recent command:

  ```bash
  !!
  ```

---

## Notes and Tips
1. Always secure your `.pem` file; unauthorized access can compromise the instance.

2. Check the `man` pages for additional command options (e.g., `man sort`).

3. Use `exit` to safely disconnect from the SSH session.

---

## **Troubleshooting**
- If you encounter connection issues:
  - Verify the public IP address of your instance.
  - Ensure port 22 is open in the security group.
  - Check key file permissions.

---

## Additional Resources
- [PuTTY Documentation](https://www.chiark.greenend.org.uk/~sgtatham/putty/)

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
