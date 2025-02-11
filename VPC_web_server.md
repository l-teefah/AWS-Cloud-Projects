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
     npm install nodemailer
     ```
     
   - Generate app-specific password:
We will be generating an app-specific password as this is more secure and and different from the regular email password. Also, a new password can be generated if you lose the password.
     
   1. **For Gmail:**

      - Enable 2-Step Verification in Google Account
      - Generate App Password: Google Account → Security → App passwords
      - Update the Gmail configuration in `Email providers configurations` in the code below by replacing `your-email@gmail.com` with your gmail address and `your-gmail-app-password` with the password generated earlier.
        
   2. **For Yahoo:**

      - Enable two-step verification
      - Generate App Password: Account Security → Generate app password
      - Update the Yahoo configuration in `Email providers configurations` in the code below by replacing `your-email@yahoo.com` with your yahoo mail and `your-yahoo-app-password` with the password generated. 

   - Select your provider by changing `SELECTED_PROVIDER` in the code below to 'yahoo' if it is not gmail. 
     
   - Create a server script:

```bash
cat << 'EOF' > app.js¨
const express = require('express');
const path = require('path');
const nodemailer = require('nodemailer');
const app = express();
const port = 80;

// Email provider configurations
const emailProviders = {
    gmail: {
        service: 'gmail',
        host: 'smtp.gmail.com',
        port: 587,
        secure: false,
        requiresAppPassword: true,
        auth: {
            user: 'your-email@gmail.com',
            pass: 'your-gmail-app-password'
        }
    },
    yahoo: {
        service: 'yahoo',
        host: 'smtp.mail.yahoo.com',
        port: 465,
        secure: true,
        requiresAppPassword: true,
        auth: {
            user: 'your-email@yahoo.com',
            pass: 'your-yahoo-app-password'
        }
    }
};

// Select your email provider here: 'gmail' or 'yahoo'
const SELECTED_PROVIDER = 'gmail';  // Change this to 'yahoo' for Yahoo Mail

// Create email configuration
const getEmailConfig = (provider) => {
    const config = emailProviders[provider];
    if (!config) {
        throw new Error(`Unsupported email provider: ${provider}`);
    }
    return {
        service: config.service,
        host: config.host,
        port: config.port,
        secure: config.secure,
        auth: config.auth,
        debug: false,
        logger: true
    };
};

// Validate email configuration
const validateEmailConfig = (config) => {
    const { auth } = config;
    if (!auth.user || !auth.pass) {
        throw new Error('Email configuration is incomplete. Please check your email and password settings.');
    }
    return true;
};

// Initialize email transporter
let transporter;
try {
    const emailConfig = getEmailConfig(SELECTED_PROVIDER);
    validateEmailConfig(emailConfig);
    transporter = nodemailer.createTransport(emailConfig);
} catch (error) {
    console.error('Email configuration error:', error.message);
    process.exit(1);
}

app.use(express.static('public'));
app.use(express.json());

// Test email configuration on startup
transporter.verify((error, success) => {
    if (error) {
        console.error('Email configuration verification failed:', error);
    } else {
        console.log('Email server is ready to send messages');
    }
});

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.post('/submit', async (req, res) => {
    const { name, email } = req.body;
    
    // Email content
    const mailOptions = {
        from: emailProviders[SELECTED_PROVIDER].auth.user,
        to: emailProviders[SELECTED_PROVIDER].auth.user,
        subject: 'New Contact Form Submission',
        html: `
            <h3>New Contact Form Submission</h3>
            <p><strong>Name:</strong> ${name}</p>
            <p><strong>Email:</strong> ${email}</p>
            <p>Received on: ${new Date().toLocaleString()}</p>
        `
    };

    try {
        // Send email
        await transporter.sendMail(mailOptions);
        
        // Send auto-response to the user
        const autoReplyOptions = {
            from: emailProviders[SELECTED_PROVIDER].auth.user,
            to: email,
            subject: 'Thank you for contacting us',
            html: `
                <h3>Thank you for reaching out, ${name}!</h3>
                <p>We have received your submission and will get back to you shortly.</p>
                <p>Best regards,<br>Your Team</p>
            `
        };
        
        await transporter.sendMail(autoReplyOptions);

        res.json({ 
            message: `Thank you ${name}! We'll contact you at ${email}`,
            success: true 
        });
    } catch (error) {
        console.error('Email sending error:', error);
        res.status(500).json({ 
            message: 'There was an error processing your request',
            success: false 
        });
    }
});

// Error handling middleware
app.use((error, req, res, next) => {
    console.error('Server error:', error);
    res.status(500).json({
        message: 'An unexpected error occurred',
        success: false
    });
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
    console.log(`Using email provider: ${SELECTED_PROVIDER}`);
});
EOF
```

**Press ENTER after pasting the script above and ensure the command return to the terminal prompt without errors. If command doesn't return to terminal prompt, type Control + D (^D) to indicate end of file.**

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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Our AWS Server</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .container {
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            text-align: center;
        }

        h1 {
            color: #2c3e50;
            margin-bottom: 30px;
        }

        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 40px 0;
        }

        .feature {
            padding: 20px;
            background: #f8f9fa;
            border-radius: 8px;
            transition: transform 0.3s ease;
        }

        .feature:hover {
            transform: translateY(-5px);
        }

        .contact-form {
            max-width: 400px;
            margin: 0 auto;
        }

        input {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        button {
            background: #3498db;
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 4px;
            cursor: pointer;
            transition: background 0.3s ease;
        }

        button:hover {
            background: #2980b9;
        }

        #message {
            margin-top: 20px;
            padding: 10px;
            border-radius: 4px;
            display: none;
        }

        .success {
            background: #d4edda;
            color: #155724;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to Our Cloud Platform</h1>
        
        <div class="features">
            <div class="feature">
                <h3>Scalable</h3>
                <p>Built on AWS infrastructure for maximum reliability</p>
            </div>
            <div class="feature">
                <h3>Secure</h3>
                <p>Enterprise-grade security features included</p>
            </div>
            <div class="feature">
                <h3>Fast</h3>
                <p>Optimized for performance worldwide</p>
            </div>
        </div>

        <div class="contact-form">
            <h2>Get Started</h2>
            <form id="contactForm">
                <input type="text" id="name" placeholder="Your Name" required>
                <input type="email" id="email" placeholder="Your Email" required>
                <button type="submit">Contact Us</button>
            </form>
            <div id="message"></div>
        </div>
    </div>

    <script>
        $(document).ready(function() {
            $('#contactForm').on('submit', function(e) {
                e.preventDefault();
                
                const formData = {
                    name: $('#name').val(),
                    email: $('#email').val()
                };

                $.ajax({
                    url: '/submit',
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(formData),
                    success: function(response) {
                        $('#message').html(response.message)
                            .addClass('success')
                            .show();
                        $('#contactForm')[0].reset();
                    },
                    error: function() {
                        $('#message').html('An error occurred. Please try again.')
                            .removeClass('success')
                            .show();
                    }
                });
            });
        });
    </script>
</body>
</html>
EOF
```
     
**Press ENTER after pasting the script above and ensure the command return to the terminal prompt without errors. If command doesn't return to terminal prompt, type Control + D (^D) to indicate end of file.**

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

   - Open a browser and enter the Public IP of your instance OR Go to EC2 instance in the AWS console and click on the public IP address. You should see the interactive web page.

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


