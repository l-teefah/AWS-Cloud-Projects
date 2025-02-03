# Build Your VPC and Launch an Interactive Web App Server

This section explains the process of creating a Virtual Private Cloud (VPC) and launching an interactive web app server in Amazon Web Services (AWS). 

---

## Step 1: Create a VPC

1. **Log in to the AWS Management Console**.

2. **Navigate to the VPC Dashboard**:

3. **Create a New VPC**:

   - Click on **Your VPCs** > **Create VPC**.

   - Enter a **Name tag** for the VPC (e.g., `InteractiveVPC`).

   - Specify a **CIDR block** (e.g., `10.0.0.0/16`).

   - Select default options for other settings and click **Create VPC**.

---

## Step 2: Create Subnets

1. **Navigate to the Subnets Section**:

   - In the VPC dashboard, click **Subnets** > **Create Subnet**.

2. **Create a Public Subnet**:

   - Select the VPC created earlier.

   - Enter a **Subnet name** (e.g., `PublicSubnet`).

   - Specify a **CIDR block** (e.g., `10.0.1.0/24`).

   - Enable **Auto-assign public IPs** and click **Create Subnet**.

---

## Step 3: Set Up an Internet Gateway

1. **Create and Attach the Internet Gateway**:

   - Go to **Internet Gateways** > **Create Internet Gateway**.

   - Enter a name (e.g., `InteractiveGateway`) and click **Create Internet Gateway**.

   - Select the created gateway and attach it to your VPC.

2. **Update the Route Table**:

   - Navigate to **Route Tables**.

   - Select the route table associated with your VPC.

   - Go to **Route** > **Edit Routes** then, add a route with the following details:

     - **Destination**: `0.0.0.0/0`

     - **Target**: **Internet Gateway** from dropdown list > **`InteractiveGateway` (Internet Gateway created earlier)**

---

## Step 4: Launch an EC2 Instance

1. **Open the EC2 Dashboard**:

   - Go to **EC2**.

2. **Launch an Instance**:

   - Click **Launch Instances**.

   - Select an **Amazon Machine Image (AMI)** (e.g., Amazon Linux 2 AMI).

   - Choose an **Instance Type** of type `t3.micro`.

3. **Configure the Instance**:

   - Edit **Network Settings**, select the VPC and public subnet created earlier.

   - Ensure **Auto-assign Public IP** is enabled.

4. **Configure Security Group**:

   - Create a new security group and edit inbound rules to allow HTTP, HTTPS, and SSH access:

     - Add **Inbound Rules** for ports:

       - **22 (SSH)** from `0.0.0.0/0`.

       - **80 (HTTP)** from `0.0.0.0/0`.

       - **443 (HTTPS)** from `0.0.0.0/0`.

5. **Launch the Instance**:

   - Create or use an existing key pair for SSH access.

   - Click **Launch Instance**.

---

## Step 5: Install and Configure an Interactive Web App Server

1. **Connect to Your Instance**:

   - Select your EC2 instance, then Connect then use Session Manager to connect to your EC2 instance. Alternatively, you can use puTTY or Terminal to SSH connect to the instance by running the commands below: 

     ```bash
     cd ~/Downloads
     chmod 400 <key-pair.pem>
     ssh -i <key-pair.pem> ec2-user@<public-ip>
     ```
- Replace `~/Downloads` with the key pair file location assuming it is not in the Downloads folder.
- Replace `<key-pair.pem>` and `<public-ip>` with the key pair file name and EC2 instance public IP address.

2. **Install and Configure Node.js**:

   - Update the instance:

     ```bash
     sudo yum update -y
     ```

   - Install Node.js and npm:

     ```bash
     curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
     sudo yum install -y nodejs
     ```

3. **Create a Basic Interactive Web App**:

   - Create a new directory for the app and navigate to it:

     ```bash
     mkdir interactive-app && cd interactive-app
     ```

   - Initialize the project and install dependencies:

     ```bash
     npm init -y
     npm install express
     ```

   - Create a server script:

     ```bash
     cat << 'EOF' > app.js¨
     const express = require('express');
     const app = express();
     const port = 80;

     app.use(express.static('public'));

     app.get('/api/greet', (req, res) => {
         res.json({ message: 'Hello, welcome to your interactive web app!' });
     });

     app.listen(port, () => {
         console.log(`App running at http://localhost:${port}`);
     });
     EOF
     ```

**Press ENTER after pasting the script above and ensure the command return to the terminal prompt without errors. If command doesn't return to terminal prompt, type Control + D (^D) to indicate `end of file`.**

  - Confirm that `app.js` was created 
  
     ```bash
     ls -l app.js
     ```

4. **Add an Interactive Frontend**:

   - Create a `public` directory:

     ```bash
     mkdir public
     ```

   - Add an HTML file for interactivity:

     ```bash
     cat << 'EOF' > public/index.html
     <!DOCTYPE html>
     <html>
     <head>
         <title>Interactive Web App</title>
         <script>
             async function fetchGreeting() {
                 const response = await fetch('/api/greet');
                 const data = await response.json();
                 document.getElementById('greeting').innerText = data.message;
             }
         </script>
     </head>
     <body>
         <h1>Welcome to My Web App!</h1>
         <button onclick="fetchGreeting()">Get Greeting</button>
         <p id="greeting"></p>
     </body>
     </html>
     EOF
     ```
     
**Press ENTER after pasting the script above and ensure the command return to the terminal prompt without errors. If command doesn't return to terminal prompt, type Control + D (^D) to indicate `end of file`.**

     - Confirm that `index.html` was created 
  
     ```bash
     ls -l public/index.html
     ```


5. **Start the Web App Server**:

   - Run the app:

     ```bash
     sudo node app.js
     ```

6. **Verify the Web App**:

   - Open a browser and enter the **Public IP** of your instance. You should see the interactive web page.

   - Click the button to fetch and display a greeting.

---

## **Additional Notes**

- This app is for demonstration purposes hence the simplicity. For production, consider using a process manager like PM2 to run the Node.js application and set up HTTPS for security.

- To scale, use an Application Load Balancer with Auto Scaling Groups.

---

# **Troubleshooting Tips**

## **Error Loading Website**
- If website doesn't load, delete the `s` at the end of `https` in the web address and reload.

## **Verify File Existence and Remove Incomplete Files**
- Ensure that `app.js` and `public/index.html` exist in the correct locations:
- Make sure that **`EOF` is on a new line** and that you **press Enter** after it.

```bash
ls -l app.js
ls -l public/index.html
```

If either file is missing or incomplete, remove it before recreating:

```bash
rm -f app.js
rm -f public/index.html
```

## **Check Network Connectivity**
If the web app is not loading, try pinging the instance’s public IP:

```bash
ping <your-public-ip>
```

If the request times out:
- Ensure **ICMP is allowed** in the **Security Group**.
- Ensure the **instance has a public IP**.
- Check **subnet routing and internet access**.

## **Check Security Group Rules**
Confirm that your instance’s **Security Group** allows inbound traffic:

```bash
aws ec2 describe-security-groups --group-ids <security-group-id>
```

Ensure **inbound rules** allow:
- **HTTP (Port 80)** from `0.0.0.0/0`
- **SSH (Port 22)** from your IP (`x.x.x.x/32`)
- **Custom ICMP** for ping testing.

## **Verify Subnet Route Table**
Check if your instance’s subnet is correctly configured for internet access:

```bash
aws ec2 describe-route-tables --route-table-ids <route-table-id>
```

Ensure there is a route:
- **Destination:** `0.0.0.0/0`
- **Target:** Internet Gateway (`igw-xxxxxxxx`)

## **Ensure the Instance Is Running**
Check the instance status:

```bash
aws ec2 describe-instances --instance-ids <instance-id>
```

Ensure the status is **"running"**.

## **Test If the Web App Is Listening**
Run:

```bash
netstat -tulnp | grep LISTEN
```

If no output is shown for **port 80** or **port 3000**, restart the server.

## **Verify Web App Response Using `curl`**
Run this command on your EC2 instance:

```bash
curl http://localhost:80
```

- If you receive a valid HTML response, your app is running.
- If not, check the logs again.

## **Debugging Using `traceroute`**
Run:

```bash
traceroute <your-public-ip>
```

If it stops before reaching your instance, check your **VPC settings**.

---


