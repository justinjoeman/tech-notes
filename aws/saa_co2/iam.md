# IAM

## Core components
* Applies to all regions at same time (global)
* No charge
* **Policies**
    * JSON documents to grant / deny permissions to a user / group / role for AWS services
    * Attached to IAM identitty eg user / group / role
    * **Managed Policies** - AWS created. Normally the base functions for a particular action or service. Eg AwsSSMAdministrator or AwsSSMReadOnly
    * **Customer managed policies** - Created by the customer
    * **Inline policy** - attached directly to user
* **User** - Login to UI or have programmatic access
    * Inline policy can be attached to a user (not best practice)
    * Create an `access_key` in other to authenticate and use CLI / SDK tools. 2 per user can be active.
    * MFA (multi-factor authentication) can be turned on per user and should be. Cannot be enforced but policies can be created to restrict access to resources if MFA is not enabled.
* **Group** - Collection of users. Main benefit will be to attach permissions to group and add users to groups to inherit those permissions
* **Roles** - Assign to `users` or `groups`
    * Roles can also be assumed given the right permissions

## Policy structure
* JSON with:
    * `Version` - unlikely to change
    * `Statement` - single or an array of statements
    * `Sid` - Optional, like a name or an identifer of some kind. Good practice to give indication of purpose of policy
    * `Effect` - `allow` or `deny`
    * `Principal` - User / group / role it applies to
    * `Action` - what it applies to eg ec2:read ec2:startinstance
    * `Resource` - the aws resource it applies to
    * `Condition` - like if s3 bucket containers xyz

* Example
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["arn:aws:s3:::bucket-name"]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": ["arn:aws:s3:::bucket-name/*"]
        }
    ]
}
```
