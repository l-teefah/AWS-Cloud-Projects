
# AWS Lambda: Character Count Function

## Overview
In this tutorial, you will create an AWS Lambda function to count the number of characters in a text file. The Lambda function will be triggered by an S3 bucket event, and the results will be reported via Amazon Simple Notification Service (SNS).

---

## Objectives
By completing this exercise, you will:
1. Create a Lambda function to count the number of characters in a text file.
2. Configure an S3 bucket to trigger the Lambda function when a text file is uploaded.
3. Set up an SNS topic to send the character count results via email.

---

## Prerequisites
- Access to the AWS Management Console.
- Basic knowledge of Python and AWS services such as Lambda, S3, and SNS.
- Create an IAM role (`LambdaAccessRole`) with the following policies:
  - **AWSLambdaBasicExecutionRole**: Provides permissions to write logs to CloudWatch.
  - **AmazonSNSFullAccess**: Provides full access to Amazon SNS.
  - **AmazonS3FullAccess**: Provides full access to S3 buckets.
  - **CloudWatchRUMFullAccess**: Provides full access to CloudWatch.

---

## Steps

### Step 1: Create the Lambda Function
1. **Navigate to AWS Lambda**:
   - Open the AWS Management Console and go to the Lambda service.
   - Click **Create Function**.

2. **Define the Function**:
   - Choose **Author from scratch**.
   - Function name: `CharacterCountFunction`
   - Runtime: Python 3.x
   - Role: Select `LambdaAccessRole`.

3. **Write the Lambda Code**:
   - Replace the default code with the following Python code:
   
     ```python
     import json
     import boto3

     def lambda_handler(event, context):
         s3 = boto3.client('s3')
         sns = boto3.client('sns')

         # Extract bucket name and file key from the event
         bucket_name = event['Records'][0]['s3']['bucket']['name']
         file_key = event['Records'][0]['s3']['object']['key']

         # Read the file from S3
         response = s3.get_object(Bucket=bucket_name, Key=file_key)
         content = response['Body'].read().decode('utf-8')

         # Count the characters
         char_count = len(content)

         # Send the result to SNS
         message = f"The character count in the {file_key} file is {char_count}."
         sns.publish(
             TopicArn='arn:aws:sns:<region>:<account_id>:CharacterCountTopic',
             Subject='Character Count Result',
             Message=message
         )

         return {
             'statusCode': 200,
             'body': json.dumps({'message': message})
         }
     ```
     
   - Replace `<region>` and `<account_id>` with your AWS Region and Account ID.

4. **Deploy the Function**:
   - Click **Deploy**.

### Step 2: Create the S3 Bucket
1. Navigate to **S3** in the AWS Management Console.
2. Create a new bucket:
   - Bucket name: `charactercount-textfiles` (**Remember bucket names are unique globally so you might need to change the name**)
   - Region: Same as the Lambda function.
3. Enable event notifications:
   - After bucket creation, navigate to the `Properties` section.
   - Scroll down and click `Create event notification` (or Add notification, depending on the UI).
   - Enter a name (e.g., `TriggerLambdaForTxt`).
   - Event types: Choose/select the checkbox for `PUT` from the list of event types.
   - Prefix and Suffix: Leave the Prefix blank if you don't need to specify a directory. In Suffix, type `.txt` to filter for text files.
   - Destination: Select `Lambda function` as the destination type.
   - Specify Lambda Function: `Choose from your Lambda functions` and from the dropdown select `CharacterCountFunction`.
   - Save the notification

### Step 3: Set Up the SNS Topic
1. Navigate to **SNS** in the AWS Management Console.
2. Create a new topic:
   - Type: Standard
   - Topic name: `CharacterCountTopic` 
3. Go to the subscription tab after creating the bucket and create a subscription:
   - Protocol: Email.
   - Endpoint: Enter your email address.
4. Confirm the subscription by checking your email and clicking the confirmation link.

### Step 4: Test the Solution
1. Upload [sample `.txt` files](samplefiles.zip) to the S3 bucket. Remember to unzip them before you upload to S3 bucket.
2. Go to the Lambda function’s **Monitoring** tab to confirm that it was triggered. Check the **CloudWatch logs** for the Lambda function to see if the event details match the .txt file you uploaded.
3. Check your emai l for the character count results.

---

## **Troubleshooting**
- Ensure the IAM role associated with the Lambda function has the correct permissions for the S3 bucket.

- Verify that the suffix .txt, correct Lambda function was selected, and event type PUT were set correctly in the notification.

- Check the CloudWatch logs for potential errors in the Lambda function execution.

---

## **Additional Resources**
- [What is AWS Lambda?](https://aws.amazon.com/lambda/)

- [Using an Amazon S3 Trigger to Invoke a Lambda Function](https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html)

- [AWS Managed Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html)

---
