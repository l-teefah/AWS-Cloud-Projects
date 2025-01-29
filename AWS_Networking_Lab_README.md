# **AWS Networking Lab: Internet Protocols Addressing and Troubleshooting**

This guide provides step-by-step instructions and insights into addressing common customer issues with AWS networking. The lab is split into three sections based on the topics of Public/Private IP addresses, Static/Dynamic IP addresses, and troubleshooting commands. 

---

## **Creating Necessary AWS Resources**

### Step 1: Set Up a VPC
1. Go to the AWS Management Console.
2. Navigate to **VPC > Your VPCs > Create VPC**.
3. Provide a name and CIDR range (e.g., `10.0.0.0/16`).

### Step 2: Create Subnets
1. Navigate to **Subnets > Create Subnet**.
2. Assign the subnet to the VPC created earlier and choose a CIDR block (e.g., `10.0.1.0/24`).

### Step 3: Launch EC2 Instances
1. Go to the **EC2 Dashboard > Launch Instances**.
2. Select an Amazon Machine Image (AMI) like Amazon Linux 2.
3. Choose an instance type (e.g., `t3.micro`).
4. Attach the VPC and subnet.
5. Assign public IPs as required.
6. Configure security groups and launch the instance.

---

## **Section 1: Public and Private IP Addresses**

### Objectives
- Investigate a customer scenario involving public and private IP addresses.
- Understand the difference between public and private IPs.
- Troubleshoot and resolve the customer’s issue.
- Summarize findings to assist the customer.

### Scenario
Someone has a VPC (`10.0.0.0/16`) with two EC2 instances (`Instance A` and `Instance B`) in the same subnet. While `Instance B` can access the internet, `Instance A` cannot. The person also inquired about the use of public CIDR ranges (e.g., `12.0.0.0/16`) for a new VPC.

### Solution Workflow
1. **Replicate the Environment**:
   - Create a VPC with the CIDR range `10.0.0.0/16` (check earlier instruction).
   - Create two public subnets and launch two EC2 instances`(Instance A & B), assigning one instance (Instance B) a public IP and the other instance (Instance A) only a private IP.

2. **Investigate the Problem**:
   - Access the EC2 console and examine networking details for both instances.
   - Note the public/private IPs and verify configurations.

3. **Troubleshooting Findings**:
   - Public IPs are essential for internet access. `Instance A` lacks a public IP, making it inaccessible from outside the VPC.
   - `Instance B` has a public IP, enabling internet connectivity.

4. **Recommendation**:
   - To ensure internet access, assign a public IP to `Instance A`.
   - Avoid using public CIDR ranges (e.g., `12.0.0.0/16`) for new VPCs as it may conflict with global internet traffic, per RFC 1918 recommendations.

---

## **Section 2: Static and Dynamic IP Addresses**

### Objectives
- Investigate a customer scenario involving static and dynamic IP assignment.
- Analyze the differences between static and dynamic IPs.
- Implement a persistent public IP solution for the customer’s EC2 instance.
- Summarize findings to assist the customer.

### Scenario
There is an EC2 instance in a public subnet. The public IP address changes every time the instance is stopped and restarted, disrupting dependent systems. A static public IP address is needed.

### Solution Workflow
1. **Replicate the Environment**:
   - Launch a new EC2 instance in a public subnet with auto-assigned public IP enabled.
   - Note the public and private IP addresses of the instance.
   - Stop and start the instance, observing the change in the public IP address while the private IP remains static.

2. **Troubleshooting Findings**:
   - Public IPs assigned by AWS are dynamic and change when instances are stopped and restarted.
   - Private IPs remain persistent within the VPC.

3. **Solution Implementation**:
   - Allocate an Elastic IP (EIP) from the EC2 dashboard. Go to **EC2 Dashboard > Elastic IPs**.
   - Allocate a new Elastic IP and associate it with an EC2 instance, ensuring a static public IP.

4. **Verification**:
   - Stop and start the instance to confirm the EIP remains unchanged as the public IP.

5. **Recommendation**:
   - Use Elastic IPs for EC2 instances that require persistent public IPs. This solution resolves the customer’s issue while ensuring system stability.

---

## **Section 3: Internet Protocol Troubleshooting Commands**

### Objectives
- Practice troubleshooting commands.
- Identify how to use these commands in customer scenarios.

### Scenario
You are a new network administrator troubleshooting customer issues. To resolve networking problems efficiently, you will use a set of key troubleshooting commands aligned with the OSI model.

### Key Commands and Use Cases

#### Layer 3 (Network): Ping and Traceroute
- **Ping Command**:
  - Tests connectivity to a target (e.g., server).

  ```bash
  ping 8.8.8.8 -c 5
  ```
  
  - Use Case: Test if the customer’s EC2 instance allows ICMP requests and validate connectivity.

- **Traceroute Command**:
  - Identifies the path and latency between the source and destination.

  ```bash
  traceroute 8.8.8.8
  ```
  
  - Use Case: Diagnose latency or packet loss issues to identify whether they occur on AWS or the ISP.

#### Layer 4 (Transport): Netstat and Telnet
- **Netstat Command**:
  - Displays active connections and listening ports.

  ```bash
   netstat -tp
   ```
   
  - Use Case: Confirm if a specific port is listening during a security scan.

- **Telnet Command**:
  - Tests connectivity to a specific port on a server.

  ```bash
  telnet www.google.com 80
  ```
  
  - Use Case: Validate that a port is correctly blocked or open based on customer security settings.

#### Layer 7 (Application): Curl
- **Curl Command**:
  - Tests communication with a web server.

  ```bash
  curl -vLo /dev/null https://aws.com
  ```
  
  - Use Case: Verify that an Apache server is running correctly by testing for a `200 OK` response.

### **Recap**
Using these commands, you can troubleshoot and resolve networking issues efficiently. By aligning these commands with the OSI model, it is possible to systematically diagnose problems and provide solutions to customers.

---

## **Summary of Findings**

1. **Public vs. Private IPs**:
   - Public IPs allow internet connectivity and are accessible globally.
   - Private IPs are restricted within the VPC and cannot access the internet without additional resources like a NAT gateway or an internet gateway.

2. **Static vs. Dynamic IPs**:
   - AWS assigns dynamic public IPs by default, which change upon instance stop/start.
   - Elastic IPs provide a permanent public IP, solving issues with persistent connectivity.

3. **Troubleshooting Commands**:
   - Commands such as `ping`, `traceroute`, `netstat`, `telnet`, and `curl` are essential tools for diagnosing and resolving networking issues.

---

## **Additional Resources**

- [Amazon EC2 Instance IP Addressing](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html)

- [Elastic IP Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html)

- [VPC CIDR Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html)

- [RFC 1918 IP Addressing](https://tools.ietf.org/html/rfc1918)

- [Ping Command Documentation](https://man7.org/linux/man-pages/man8/ping.8.html)

- [Traceroute Command Documentation](https://man7.org/linux/man-pages/man8/traceroute.8.html)

---

