# IAM and organisations

## IAM Core components
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

## IAM Policy example

IAM policy is just set of security statements for AWS to allow or deny access to resources. Usually done in JSON. An example policy statement:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3FullAccess",
            "Effect": "Allow",
            "Action": ["s3:*"],
            "Resource": ["*"]
        },
        {
            "Sid": "S3DenySecurityLogs",
            "Effect": "Deny",
            "Action": ["s3:*"],
            "Resource": ["arn:aws:s3:::justinjoeman-security", "arn:aws:s3:::justinjoeman-security/*"]
        }
    ]
}
```

This policy would allow me to attach the policy to an IAM user / group / role that I wanted to grant permissions for. It would allow the IAM user / group / role to access all S3 buckets in the account, but deny access to the `justinjoeman-security` bucket as well as the objects in the bucket.

### What types of policies are there?

`Inline policy` - attaching the policy directly to an IAM user for example. Creating a custom one to allow creation of EC2 instances for example and then attaching it to each IAM user you want to be able to do this. Not really best practice.  Best used for special or exceptional rights or changes.

`Managed policy` - created as its own object. You create an IAM policy first and then attach those to the IAM user / group you want the policy to apply to. Best for normal default rights. Reusable, low management overhead.

You have 2 main types of Managed policies:

* AWS Managed policies - created by AWS but may not fit the
* Customer managed policies - ones a user would create and manage to fit the use case for your business needs


### Exam tips
* Explicit Deny takes priority over everything. Overules everything else. 
* Explicit Allow follows second. Takes effect unless there is an explicit deny (deny statement) 
* If neither above apply, then the defualt implicit deny takes effect.
* "If not allowed access, they will not have access" eg default assumption is an IAM user / group / role is denied unless you create a policy to allow it.
* Just remember "Deny, Allow, Deny" for the priority order - Explicit Deny, Explicit Allow, Deny by default

## IAM user

"An identiy used anything requiring long term AWS access". For example a human user, application access or service accounts to do things.

Before a `Principal` (User, application, service, group etc) can use any AWS resources it must be _authenticated_. It does this by making a request to IAM with some credentials that are associated with the IAM user. If I had a user called `justinjoeman`, AWS holds either a username / password combo or a set of access keys which should be secret and only used to prove that the `principal` is that user. It will make a request with the relevant credentials, IAM will authenticate the principal so it now becomes an `authenticated identity`. 

At this stage as an authenticated identity, I may try to access a resource or do something. AWS and IAM will then check if the principal is `authorised` to do the requested action. 

### Exam tips
* `Authentication` is confirming who / what a principal is
* `Authorisation` is confirming or denying what a principal is or isn't allowed to do
* S3 Bucket arn is *globally unique*, the others are account specific.
* Max of `5000` IAM users per account as it is a global service
* IAM user can be added to a maxibum of `10` IAM groups
* *IAM account limits have design implications* - for example if merging AWS accounts for large company mergers and will go over this limit, or internet facing app where users sign up. In such a circumstance it would be wise to consider using IAM Roles & Identidy Federation to fix this. Basically using another source such as Active Directory or Google organisation to authenticate your users who then assume roles in the relevant AWS account(s). Creating an IAM user for each user (if a large amount of users) in this circumstance is going to be the wrong answer in the exam!

## IAM groups
Simply put, IAM groups are *containers* for IAM users. Exist to make managing IAM users easier. Cannot login to a group.

### Exam tips
* Users can be members of more than one group. Generally want to group organisation functions together
* Groups can have policies attached to them
* An IAM user can have both inline policiies and the policies attached to groups they are a member of.
* No default IAM group that contains all the IAM Users in an AWS account. If you wwant this you'll have to create and manage yourself.
* IAM Groups *DOES NOT ALLOW* nested groups - groups within groups
* List of `300` groups per account - can be increased with a support ticket
* *Groups are not a true identity* - they cannot be referenced by arn to allow access to say an S3 bucket. Only IAM Users and Roles can be used for this.

## IAM Roles
A type of identity which exists inside an AWS account. Role represents a level of access, short term by other identities. So an IAM user or another identity will assume a role, gain access to any policies attached to that role. For example assume you have a federated identity in Active Directory.

### When and where to use IAM Roles?
* When using Single Sign On (SSO)
* When greather than 5000 Identities
* For AWS services themselves. For example AWS Lambda or EC2 to read secrets from AWS Secrets manager. If you didn't allow this to assume roles you'd need to hard code secrets and details into your application. Not best practice at all. 
* Emergency or unusual situations. For example if you are on help desk but have an urgent customer support query that needs to be able to stop a really expensive EC2 instance created by accident.
* Another example is an IAM user needs to elevate privileges to carry out a specific task.
* For an external IdP (Identity provider)
* Web Identity Federation eg Facebook, Google, Twitter. Use the Web Id Federation to assume roles in your AWS account to access your service.
* Cross account access eg My Company AWS account and storing data inside a client AWS account. They could create a role in the client account, grant permissions for particular users / aws services to assume the client role from my company account to upload data into resources in their account.

### Exam tips
* Generally want to use IAM Roles when you have an unknown number or multiple principals.
* `Trust Policy` - controls who can assume the role. For example an external Active Directory user, a facebook user or an AWS services or IAM Users in the same or other accounts.
* `Permissions Policy` - What is allowd to be accessed. Think of it like an IAM Policy.
* Time limited and expire after a set amount of time. After this the identity will need to reassume the role to continue to have access to resources inside the AWS account.
* When role is assumed, temporary credentials are generated by the AWS Secure Token Service (STS). If you see `sts:AssumeRole` somewhere in the question or answer, you know IAM Roles are involved. 

## Service-linked Roles & PassRole
### Service linked
* Used in a very specific set of situations
* An IAM role linked to a specific AWS service
* Predefined by service
* Providing permissions that a service needs to interact with other AWS services on your behalf
* Service might create / delete the role or allow you to during the setup or within IAM
* Key difference between IAM + Service linked roles - cannot delete service linked role

### PassRole
* Scenario - IAM User tries to create a CF stack. Default way is AWS uses the permissions of IAM user to create the resources. Therefore IAM user needs permissions to create CF stack + permissions to the resouces
    * Another way of doing it would be granting the IAM user the ability to pass a role. Therefore IAM user can pass an infrastructure creation role into CF stack to create the resources with.
    * This means IAM user can operate on much lower permissions (least privilege)
* Needs `iam:ListRoles` and `iam:PassRole` to work.


## AWS Organizations

This is a service that helps you manage multiple AWS accounts with reduced overhead.

### Setup
* One standard AWS account to be an AWS organization - this becomes the management account (previously master account)
* From here you can invite other existing AWS accounts into the organization. They then become member accounts
* Each organization will have 1 management account and x number of member accounts.
* You can also created accounts from directly within the organization - just need a unique email address and AWS handles the rest.
* Structure is hierarchical - think like Active Directory tree structure with OUs.
    * You have the `Organization Root` which is the top or root container (not to be confused with root user of AWS Account)
    * Then will follow an OU pattern where they can contain member accounts 
* Member accounts pass their billing info to the Management account, effectively `consolidated billing` with all payment taken with the details of the card in the management account. One bill for all the accounts in the AWS organization.
* Also feature Service Control Policiies (SCP) so you can control what each account is able to do. Think like Active Directory group policy

### Process to create organization and add accounts via console
* Login to the account you want to be the Management account -> AWS Organizations -> Create organization
    * Once done -> Add an AWS Account -> Add existing account -> Add the email address of the root user or the account ID
* In the invited account 
    * Login -> AWS Organizations -> Invitations -> Review and accept
    * Go to IAM -> Create Role -> Entity another AWS account -> Add Account ID of the Management account -> Add a permission policy for example AdministratorAccess -> Call role `OrganizationAccountAccessRole` (this is the same name AWS would use if we created a new account via the organization instead of inviting existing account)

### Exam tips
* With consolidated billing or AWS organizations, you may see the management account referred to as the `payer account` or `master account`.
* Some services become cheaper the more they are used and also can pay in advance - therefore using organizations you can benefit from this.
* If using organizations best practice is to have 1 account (management or another) where all your identities are used to login (via SSO or an IdP or IAM Users) and they then assume roles in the other member accounts that they need access to.

## Service Control Policies (SCP)

Feature used to restrict AWS accounts inside an organisation. You attach the SCP to organization as a whole by attaching to the root OU, to OUs created per environment eg Production or Development, or directly to specific AWS accounts. Think like how you can attach a group policy to an OU in Active Directory. 
* Works in an inheritance model. So if I attach policy to Production OU and under that there are other OUs, all the OUs and accounts under Production OU will inherited
* SCP DO NOT GRANT PERMISSIONS - only set the boundary.
* For example you might want to restrict access to S3 or types of EC2 instances that can be created
* JSON policy format which follows the default AWS security pattern of "Deny, Allow, Deny".
* Want to consider the different approaches
    * Have SCP allow everything by default and then add statements to deny what you want to block - low management overhead and benefit access for new services
    * Have a blank policy document and then add in what you want to allow - everything implicitly denied by default. Higher management overhead but more control.

### Exam tips
* The management account is never affected by SCP even if SCP is attached directly to the account or to the root OU. For this you might want to not deploy any resources to the management account as it cannot be restricted in this way.
* SCPs are "account permission boundaries" - they limit what the account can do, even the root user. So if account was unrestricted, it would do 100% of things and account root user also can do 100% of things. If you restricted 20% of the member account, the account is capable of doing 80% of things and the account root user is capable of doing 100% of the 80% that it is allowed to do. Bit confusing but its like a tap filling a glass. If you make the glass smaller you can still end up with a full glass, just less actual water.
* The effective permissions allowed in an account are where the allowed SCP and the permissions for an IAM policy in an account overlap.

## Security Token Service (STS)
Service that underpins many of the identity processes in AWS
* Generates temporary credentials when `sts:AssumeRole` is used
    * Temp credentials contain
        * `AccessKeyId` - unique ID of credentials
        * `Expiration` - Date and time it will expire
        * `SecretAccessKey` - used to sign requests
        * `SessionToken` - unique token which is passed through with all requests
* Similar to access keys (access key and secret key), except they expire and don't beloing to the identity assuming the role.
    * eg expire after 1 hour
* Requested by another identity eg an AWS identity or an External one, eg AD, Twitter, Facebook etc aka **web idenity federation**
* Access is only granted if the requester has permissions to assume the role being requested

## IAM Permissions boundaries & use cases
* Only impact identity permissions
* Don't themselves grant access - effectively like a wall. Maximum permissions an identity can receive
* Anything outside the boundary is an ineffective permission. Example might set a permission boundary to be 5, but an IAM permissions might have 8. Only 5 of the 8 will be applied and the 3 outside the boundary would not be effective.

### Use case
* During delegation for example an account admin wanting to delegate IAM rights to another user to update permissions but not for them to be able to add FullAdministratorAccess to themselves or other users.

### Process
+ Create IAM policy that limits AWS permissions and limit any IAM to `${aws:username}` - the boundary that allows user to manage their own IAM user password etc:
```
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "ServicesLimitViaBoundaries",
          "Effect": "Allow",
          "Action": [
              "s3:*",
              "cloudwatch:*",
              "ec2:*"
          ],
          "Resource": "*"
      },
      {
          "Sid": "AllowIAMConsoleForCredentials",
          "Effect": "Allow",
          "Action": [
              "iam:ListUsers","iam:GetAccountPasswordPolicy"
          ],
          "Resource": "*"
      },
      {
          "Sid": "AllowManageOwnPasswordAndAccessKeys",
          "Effect": "Allow",
          "Action": [
              "iam:*AccessKey*",
              "iam:ChangePassword",
              "iam:GetUser",
              "iam:*ServiceSpecificCredential*",
              "iam:*SigningCertificate*"
          ],
          "Resource": ["arn:aws:iam::*:user/${aws:username}"]
      }
  ]
}
```
+ Create and/or attach the relevant admin policy that that the delegated user needs 
+ Create / attach the permissions boundary that limits what the user can do:
```
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "CreateOrChangeOnlyWithBoundary",
          "Effect": "Allow",
          "Action": [
              "iam:CreateUser",
              "iam:DeleteUserPolicy",
              "iam:AttachUserPolicy",
              "iam:DetachUserPolicy",
              "iam:PutUserPermissionsBoundary",
              "iam:PutUserPolicy"
          ],
          "Resource": "*",
          "Condition": {"StringEquals": 
              {"iam:PermissionsBoundary": "arn:aws:iam::MANAGEMENTACCOUNTNUMBER:policy/a4luserboundary"}}
      },
      {
          "Sid": "CloudWatchAndOtherIAMTasks",
          "Effect": "Allow",
          "Action": [
              "cloudwatch:*",
              "iam:GetUser",
              "iam:ListUsers",
              "iam:DeleteUser",
              "iam:UpdateUser",
              "iam:CreateAccessKey",
              "iam:CreateLoginProfile",
              "iam:GetAccountPasswordPolicy",
              "iam:GetLoginProfile",
              "iam:ListGroups",
              "iam:ListGroupsForUser",
              "iam:CreateGroup",
              "iam:GetGroup",
              "iam:DeleteGroup",
              "iam:UpdateGroup",
              "iam:CreatePolicy",
              "iam:DeletePolicy",
              "iam:DeletePolicyVersion",
              "iam:GetPolicy",
              "iam:GetPolicyVersion",
              "iam:GetUserPolicy",
              "iam:GetRolePolicy",
              "iam:ListPolicies",
              "iam:ListPolicyVersions",
              "iam:ListEntitiesForPolicy",
              "iam:ListUserPolicies",
              "iam:ListAttachedUserPolicies",
              "iam:ListRolePolicies",
              "iam:ListAttachedRolePolicies",
              "iam:SetDefaultPolicyVersion",
              "iam:SimulatePrincipalPolicy",
              "iam:SimulateCustomPolicy" 
          ],
          "NotResource": "arn:aws:iam::MANAGEMENTACCOUNTNUMBER:user/bob"
      },
      {
          "Sid": "NoBoundaryPolicyEdit",
          "Effect": "Deny",
          "Action": [
              "iam:CreatePolicyVersion",
              "iam:DeletePolicy",
              "iam:DeletePolicyVersion",
              "iam:SetDefaultPolicyVersion"
          ],
          "Resource": [
              "arn:aws:iam::MANAGEMENTACCOUNTNUMBER:policy/a4luserboundary",
              "arn:aws:iam::MANAGEMENTACCOUNTNUMBER:policy/a4ladminboundary"
          ]
      },
      {
          "Sid": "NoBoundaryUserDelete",
          "Effect": "Deny",
          "Action": "iam:DeleteUserPermissionsBoundary",
          "Resource": "*"
      }
  ]
}
```

## Policy evaluation logic
Useful for determining the final identity permissions. You consider:
* Organisation SCP
* Resource policies
* IAM Identity boundaries
* Session poliicies
* Identity policies
* How multi account affects this process

### With single account
- Is there an `Explicit Deny`?
    - If `yes` then stop processing
    - If `no` then move to SCP evaluation
- `SCP` - Does an SCP exist?
    - If `yes` then does the SCP `allow` the action?
        - If `no` then there is an implicit `deny` - stops evaluation
        - If `yes`, then continue to resource policies
- `Resource policies` - does it `alloow` the action?
    - if `yes`, then processing stops.
    - if `no` then processing goes to permissions boundaries
- `Permissions boundaries` - is there an applicable boundary
    - if `yes`, does it allow action?
        - if `no` then stops.
        - if `yes` then move to session policies
- `Session policies` - if using this then an IAM role is being used. Does role allow action?
    - if `no` - then implicit deny and processing stops
    - if `yes` then move to identity policies
- `Identity policies` - reviews any explicit allow
    - if `yes` then allow
    - if `no` - then implicit deny, processing stops

### with multi account
- Both accounts need to allow access from the order for it to work
- Anything else (eg allowed in one but not the other) - then it is denied.