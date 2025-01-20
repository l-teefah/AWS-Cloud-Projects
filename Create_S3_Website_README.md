# Launching a Static Website on Amazon S3 Using AWS CLI and Management Console (Free Tier, No Pre-Existing Files)

This guide will help you launch a static website on Amazon S3 using both the AWS CLI and the AWS Management Console. The setup assumes you have no pre-existing files and uses AWS free tier resources.

## Prerequisites

- An AWS account (ensure the free tier is active).
- Basic familiarity with the AWS Management Console.

---

## Create an Index File
Create a simple `index.html` file locally to act as the main page of your website, copy the code below into a text editor and save as html file or download here [Download index.html](./index.html). For example:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            margin-top: 50px;
        }
        button {
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <h1>Welcome to My Interactive Static Website</h1>
    <p>This site is hosted on Amazon S3 using the AWS CLI.</p>
    <button onclick="alert('You clicked the button!')">Click Me!</button>
</body>
</html>
```
---

## Method 1: Using AWS Management Console

### Step 1: Create an S3 Bucket
1. Log in to the [AWS Management Console](https://aws.amazon.com/console/).
2. Navigate to the **S3** service.
3. Click **Create bucket**.
4. Provide a unique bucket name (e.g., `my-static-website-123`) and choose your desired region.
5. Configure settings:
   - **Block Public Access settings for this bucket**: Uncheck "Block all public access" to allow public access (e.g., for hosting a static website).
   - Acknowledge the warning about public access.
6. Click **Create bucket**.

### Step 2: Enable Static Website Hosting
1. Open your newly created bucket.
2. Go to the **Properties** tab.
3. Scroll to **Static website hosting** and click **Edit**.
4. Select **Enable**.
5. Specify the **Index document** as `index.html`. For **Error document**, you can specify `error.html` (optional).
6. Click **Save changes**.

### Step 3: Upload Files to S3 Bucket
1. Open the **Objects** tab in your bucket.
2. Click **Upload**.
3. Drag and drop your `index.html` file or click **Add files** to browse for it.
4. Click **Upload**.

### Step 4: Add Bucket Policy
1. Navigate to the **Permissions** tab.
2. Scroll to **Bucket Policy** and click **Edit**.
3. Add the following policy (replace `<your-bucket-name>` with your bucket name):

    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::<your-bucket-name>/*"
        }
      ]
    }
    ```
    
4. Save the policy.

### Step 5: Allow Public Access
1. Navigate to the **Permissions** tab.
2. Scroll to **Public Access** and uncheck the box to allow public access.

### Step 6: Test the Website
1. Go to the **Properties** tab and copy the **Endpoint** URL under **Static website hosting**.
2. Paste the URL into your browser to view your website.

---

## Method 2: Using SSH, AWS Instance Connect or CLI access

### Step 1: Create an EC2 Instance with Key Pair (Optional for Authentication)
1. Navigate to the **EC2** service in the AWS Management Console.
2. Launch an instance and generate a key pair for SSH access.
3. Create a security group while launching the isntance and allow SSH connections (port 22) in the inbound rule **or** check and add inbound rule if you will be using an existing security group.
4. Download the key pair and store it securely, as it will be used to access your instance.

### Step 2: Create a New IAM User for S3 Access
1. Go to the **IAM** service in the AWS Management Console.
2. Create a new user or use an existing IAM user.
3. Attach the **AmazonS3FullAccess** policy to the user.
4. Alternatively, you can check the **AdministratorAccess** box to add the user to the admin group.
5. Generate the **Access Key ID** and **Secret Access Key** for the user from the Security Credentials tab.
6. To configure the CLI, run:

    ```bash
    aws configure
    ```
    
Provide your **Access Key ID**, **Secret Access Key**, **Region**, and default output format.
    
### Step 3: Create an S3 Bucket
Run the following command to create a new bucket:

    ```bash
    aws s3api create-bucket 
    --bucket <my-static-website-123> 
    --region us-east-1 
    --create-bucket-configuration LocationConstraint=us-east-1
    ```

**Replace `<my-static-website-123>` with desired bucket name until accepted and adjust the region if necessary.**

### Step 4: Enable Public Access
1. Add a bucket policy:

    ```bash
    aws s3api put-bucket-policy --bucket <my-static-website-123> --policy '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::my-static-website-123/*"
        }
      ]
    }'
    ```

2. Enable static website hosting:

    ```bash
    aws s3 website s3://<my-static-website-123>/ 
    --index-document index.html 
    --error-document error.html
    ```

### Step 5: Upload the File to S3 & extract website endpoint
Upload the `index.html` file to your S3 bucket:

    ```bash
    aws s3 cp index.html s3://<my-static-website-123>/
    ```

    ```bash
    aws s3api get-bucket-website --bucket <my-static-website-123>
    ```

Copy the **Endpoint** URL and open it in your browser. Your interactive website should now be live.

### Step 6: Automate Website Updates
1. Create an update script:

    ```bash
    vi website-update.sh
    ```

2. Add the following content to the script:

    ```bash
    #!/bin/bash
    aws s3 sync /path/to/static-website/ s3://<my-static-website-123>/ 
    --acl public-read
    ```
**`/path/to/static-website/` means the actual file path on your local machine where your website files are stored.**

3. Save and make the script executable:

    ```bash
    chmod +x website-update.sh
    ```

4. Run the script to update the website:

    ```bash
    ./website-update.sh
    ```

---

## **Notes**

- AWS Free Tier includes 5 GB of standard storage, 20,000 GET requests, and 2,000 PUT requests per month, sufficient for small-scale static websites.
- Always monitor your AWS usage to avoid unexpected charges.

## **Troubleshooting**

- **Access Denied Errors**: Ensure the bucket policy and object permissions allow public access.

- **Bucket Name Conflicts**: S3 bucket names must be globally unique.

- **403 Forbidden Errors**: Ensure the correct permissions are applied to both the bucket and objects.

- **Names Replacement With Appropriate Names**: Names enclosed in `<>` needs to be replaced with the correct names you created.

Enjoy hosting your static website with AWS CLI and Management Console!
