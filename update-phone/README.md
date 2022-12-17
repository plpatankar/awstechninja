## Features
With automated shell script you may update contact information for multiple AWS accounts and their primary phone numbers. Typically, you need to update primary phone number while keeping other contact information same. Script usages ‘get-contact-information’ and ‘put-contact-information’ APIs to get the old contact details and update only the phone number. It also logs the old contact details so that if something goes wrong it will be helpful to restore.  
Script also use assume-role to switch to multiple accounts and perform the updates. 

## How to use
Load the AWS AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_SESSION_TOKEN for the IAM user in launch account. 
 
export AWS_ACCESS_KEY_ID=< ACCESS_KEY_ID >
export AWS_SECRET_ACCESS_KEY= < SECRET_ACCESS_KEY >
export AWS_SESSION_TOKEN= < SESSION_TOKEN >
 
Replace following information in the script as per your details – 
 
NewPhoneNumber='New Phone number'

RoleName='Role Name to assume into target account'

Log files account-contact-info.logs and updated-account.logs will be created by script for logging old contact information and list of accounts which are updated by script to track. 
