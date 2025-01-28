
# Amazon Linux AMI Lab Instructions

This guide provides a step-by-step guide to using an Amazon Linux Amazon Machine Image (AMI). The lab reinforces basic command-line interface functionality and builds a foundation for further exploration of Linux commands.

---

## Prerequisites
Ensure you have the following:
1. An AWS account.
2. Access to AWS Management Console.
3. An SSH client:
   - **Windows**: PuTTY
   - **macOS/Linux**: Terminal

---

## Steps to Set Up the Environment

### 1. **Create Resources in AWS**

1. **Create a VPC**:
   - Navigate to the **VPC** section under **Networking** in the AWS Management Console.
   - Create a new VPC with a CIDR block (e.g., `10.0.0.0/16`) or use default existing VPC.

2. **Create a Public Subnet**:
   - Inside the VPC, create a public subnet with a CIDR block (e.g., `10.0.1.0/24`) or use default existing public subnet.
   - Enable auto-assign public IPs.

3. **Launch an Amazon Linux EC2 Instance**:
   - Navigate to **EC2** > **Launch Instances**.
   - Select **Amazon Linux 2 AMI**.
   - Choose the **t3.micro** instance type.
   - Place the instance in the public subnet.
   - Create and download a key pair (PEM file for macOS/Linux or PPK file for Windows).
   - Open the security group and allow SSH access (port 22) from your IP.

---

### 2. **Access the EC2 Instance via SSH**

#### **Windows Users**
1. Download **PuTTY** if not already installed.
2. Convert the PEM key file to PPK format using PuTTYgen:
   - Open PuTTYgen.
   - Load the PEM file and save the private key as a PPK file.
3. Open **PuTTY**:
   - Hostname: `<Public IP of EC2 instance>`.
   - Authentication: Use the PPK file.
4. Connect to the instance as `ec2-user`.

#### **macOS/Linux Users**
1. Open terminal and navigate to the directory containing the PEM file (in this case, it is assumed to be `Downloads`.

   ```bash
   cd ~/Downloads
   ```
   
2. Update permissions for the PEM file:

   ```bash
   chmod 400 <pem_file_name.pem>
   ```
   
**Replace `<pem_file_name.pem>` with your key pair file name.**

3. Connect to the instance using SSH:

   ```bash
   ssh -i labsuser.pem ec2-user@<Public IP>
   ```
   
**Replace `<Public IP>` with your EC2 instance Public IP.**
   
4. Type `yes` to confirm the first connection.

---

### 3. **Explore the Linux Manual Pages**

#### **View the `man` Pages**
1. In the SSH session, enter the following command to open the manual pages for the `man` program:

   ```bash
   man man
   ```

#### **Key Sections in the `man` Pages**
- **NAME**: This section provides the name of the command or program and a brief description of its purpose.
- **SYNOPSIS**: This section describes the syntax of the command, including the options and arguments it accepts. It provides a quick overview of how to use the command.

- **DESCRIPTION**: This section gives a detailed explanation of what the command does, its functionality, and its use cases. It often includes background information and elaborates on specific features.

- **OPTIONS**: This section lists and explains the options or flags that can be used with the command. Each option is usually accompanied by a description of its effect.

- **EXAMPLES**: This section provides practical examples of how to use the command in different scenarios. It is particularly helpful for understanding real-world applications.

- **FILES**: This section lists any files that are associated with the command, such as configuration files or output files.

- **EXIT STATUS**: This section describes the exit codes that the command may return and their meanings (e.g., `0` for success, non-zero for errors).

- **SEE ALSO**: This section references related commands, programs, or resources that might be useful for further exploration or understanding.

#### **Navigation**
- Use the **Up** and **Down** arrow keys to scroll.
- Press **q** to exit the manual pages.

---

### 4. **Terminate the EC2 Instance**
1. Navigate to the **EC2 Dashboard**.
2. Select the instance and choose **Actions > Instance State > Terminate Instance**.
3. Confirm the termination.

---

## **Additional Resources**
- [Amazon EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)

- [Amazon Machine Images (AMI)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)

- [AWS Training and Certification](https://aws.amazon.com/training/)

---

