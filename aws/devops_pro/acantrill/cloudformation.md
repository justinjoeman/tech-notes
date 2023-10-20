# Cloudformation

AWS's IaC tool where you create a template of resources to be created / updated / deleted in your cloudformation stack. 

## Logical and Physical resources

* Logical resources -> the resources inside your CF template. Effectively what you want to create eg
```
Resources:
  MyLogicalResource:
    Type: AWS::EC2::Instance
    Properties:
      ImageID: ami-f4534
      InstanceType: "t3.micro"
```
* Physical resource -> effectively what is created -> So this will be the actual EC2 Instance.
* When you make a CF stack, AWS will create physical resources to match the specs of the logical resource.

## CF Template and Psuedo Parameters

* Allows you to reuse templates and not hardcode values - making them portable to different regions or accounts for example (best practice)
* Can also put conditional info in them such as `Defaults`, `AllowedValues`, `Min` and `Max` length, `AllowedPatterns`, `NoEcho` (for passwords for example) & `Type`
* AWS also provide some account level ones you can use to reference such as `AWS::StackId`, `AWS::AccountId` and more.

You might use it something like:

```
Parameters:
  InstanceTyoe:
    Type: String
    Default: 't3.micro'
    AllowedValues:
      - 't3.micro'
      - 't3.medium'
      - 't3.large'
```

## Intrinsic functions

These include:
* `Ref` or `Fn::GetAtt` -> Used to reference logical resources or get particular attributes of them. Attributes will be dependant on type created.
* `Fn::Join` & `Fn::Split` -> Exactly what you think it does - does or splits a string based on a delimiter
* `Fn::GetAZs` & `Fn::Select` -> Generally these are used together. First you'd get the AZs or list of them. Then use select to pick one.
* Conditions Fn:: [IF, And, Equals, Not & Or]
* `Fn::Base64` & `Fn::Sub` -> Encodes text to Base64 (for example during UserData for EC2 instance) or substitute data in a string. eg `!Sub 'URL = https://${url}.${domainname}'`
* `Fn::Cidr` -> Used to dynamically assign CIDR if you're creating a VPC via CF without having to hardcode the subnet ip ranges
* `Fn::ImportValue` -> Import a value from another CF stack if that has an output at the end
* `Fn::FindInMap` -> Look for a value in a map in a CF stack
* `Fn::Transform`

## Mappings
* Basically a key value pair that can be used in a CF template
* Main use case is to allow portability. For example you could create a map of AMI ID's based on region. So if region is `eu-west-1` it'll use `AMI-12345` and if region is `us-east-1` it would use `AMI-56789`
* Can have 1 key, or a Top and Second level.
* Uses the function `!FindInMap`

```
Mappings:
  RegionMap:
    eu-west-1:
      AMI: "AMI-12345"
    us-east-1:
      AMI: "AMI-56789"
```

Query it using the format `!FindInMap [ MapName, TopLevelKey, SecondLevelKey]` so it would look something like `!FindInMap [ "RegionMap", "eu-west-1", "AMI"]`

## Conditions
* An optional section of a template
* Conditions can be `TRUE` or `FALSE`
* Processed before resources are created
* Use other intrinsic functions like `AND`, `EQUALS`, `IF`, `NOT`, `OR`

Rough example so this would only create an elastic ip if the environment is `prod`

```
Parameters:
  Environment:
    Type: String
    AllowedValues:
      - 'dev'
      - 'prod'

Conditions:
  IsProd: !Equals
    - !Ref Environment
    - 'prod'

Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
     ...

  ElasticIP:
    Type: AWS::EC2::EIP
    Condition: IsProd
    Properties:
      ...
```

## DependsOn
* Won't create the resource until the dependency is created. For example if making an EC2 instance but also an IAM role to attach to that instance you may use a `DependsOn`. This will create an explicit dependency if you want things to be done in a particular order. 

psuedo-cf template:
```
Resources:
  InstanceProfile:
    Type: ...
    Properties: ...

  EC2:
    Type: ...
    DependsOn: InstanceProfile
```

## `WaitCondition`, `Creation Policy` and `cfn-signal`
Allows CF more flexibility in determining when something is complete. For example the use case of creating an EC2 instannce with user data, if created via a CF stack it will say creation complete when AWS reports instance ready. But we may not want it to report ready until the data data has run successfully and final instance state is in the way we want it. This is when these things can come in handy.

* cfn-signal is something running on the actual EC2 instance that sends the signals back to AWS
* Max timeout is `12 hours`
* Will wait for `X` number of success signals before moving the CF Resource to complete / success
* If cfn-signal sends a failure signal will explicitly fail the process / stack
* AWS recommends for EC2 / Autoscaling groups to use `CreationPolicy`, for others that have external requirements to maybe used a `WaitCondition`
* `WaitCondition` does what you think it does - waits for a specified time before proceeding. These are a separate resource compared to `CreationPolicy`

## CFN Nested Stacks
* Nested stacks could be used when resources being provisioned share a life cycle and are related. Other times this is useful is when you are creating resources with more than `500` resources in a stack (an AWS hard limit). Another reason to use is if you need to reuse resources. So for example if you created a nested stack with 5 templates, you could effectively create `2500` resources.
* They allow modular templates making code reusable
* With nested stacks you're only reusing the templates themselves, not actual resources
* *Only use when everything is lifecycle linked!*
* Start with 1 stack known as the `Root` stack - the only stack created manually by an entity. Basically what is created first.
* `Parent stack` is a way to refer to anything that has its own nested stack
* With nested stacks you create them as a resource:
```
Resources:
  VPCStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://...
      Parameters:
        Param1: ...
        Param2: ...

  EC2Stack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://...
      Parameters:
        Param1: ...
        Param2: ...
```

## Cross Stack References

* Using `Outputs` from a stack, they can be exported and made visible for other stacks to use, you can reference those particular resources using `!ImportValue` or `Fn::ImportValue` in another CF stack.
* Exports must have a unique name in the region

## Stack Sets
* Allows you to deploy stacks across different accounts and regions
* Think of a stackset being a "container" in an admin account (the account where you run the admin for your stackset) 
    * These contain stack instances which reference stacks
* Stack instances and stacks will be deployed / are contained in "target accounts" - where you want the resources deployed.
* Uses `self managed` or `service managed` IAM roles.

### Terms
* `Concurrent accounts` - how many AWS accounts can be used at the same time. So if you need to deploy to 10 accounts and you set this at `5`, your stackset will deploy twice, first time to 5 accounts and then second time to 5 accounts to deploy a total of 10 accounts.
* Failure Tolverance - the amount of individual deployments that can fail before the stackset deployment is determined as a failure
* Retain stacks - Remove stack instances from a stackset. By default will remove any of the stacks that are in the target accounts. 

### Use cases
* Enabling AWS config across multiple accounts
* Applying AWS config rules such as MFA or EBS encryption etc
* Creating IAM Roles for cross account access at scale

## DeletionPolicy
* By default if you delete a resource from a stack, it will delete the physical resource that is created when the template is applied. Might cause unintended data loss.
* Options for this are `Delete` (default), `Retain` and `Snapshot` if supposed by some services, most likely DB or storage services like EBS, Elasticache, Neptune, RDS, Redshift etc
* If you `Retain` or `Snapshot`, you'll need to clean up the resources after manually. Not doing so will cost you $$$$!
* ONLY APPLIES TO DELETE operations, NOT REPLACE! For example if applying an update stack, and the RDS resource needs replacing, a retain policy will have no affect and data will be lost.

## StackRoles
* By default, CF uses the permissions of who is creating the stack to create the resources. So the entity will need permissions to create, update and delete to be able to do what it needs to do. StackRoles gets arounds this as it allows CF to assume role and then do the provisioning. Allowing a form of role separation. This means the entity only needs permissions to Create the stacks, but the stackrole will have the permissions to create / update the necessary resources.
* Example - A developer needs to create bunch of resources for deployment but his IAM user only has restricted permissions. An admin user in the AWS account can create an IAM role that has permissions to create resources. The developer can pass this role into Cloudformation so the resources are created with this role. This way the developer cannot directly create / delete resources in the account but is able to create stacks for their application needs.

## CloudformationInit / cfn-init
* `CloudFormationInit` and `cfn-init` are tools which allow a desired state configuration management system to be implemented within CloudFormation. A native CF feature. Runs during bootstrapping when instances first created.
* Runs ONCE
* An alternative to `UserData` for EC2.
* `UserData` is procedural. `UserData happens in order so effectively "how" to bootstrap` vs `cfn-init being the desired state`
* `cfn-init` is a helper script - installed on EC2 OS so can run across linux distributions and windows

Example:
```
EC2Instance:
  Type: AWS::EC::Instance
  Parameters:
    Userdata:
      Fn::Base64: !Sub |
        #!/bin/bash -xe
        yum -y update
        /opt/aws/bin/cfn-init --stackname ${AWS::StacId} --resource EC2Instance --configsets wordpress_install --region ${AWS::Region}
    MetaData:
      AWS::CloudFormation::Init:
        configSets: "<configkey>"
        install_cfn: "<configkey>"
        configure_wordpress: "<configkey>
```

* Each `ConfigKey` has its own subset of data. Things like what packaghes to install, groups, files, services etc to run or use as part of executing that bit of helper script.
* You can create `ConfigSets` which are basically a collection of `ConfigKeys` that you will execute.

## cfn-hup
* An extra tool, a helper daemon that can be installed.
* Detects changes in the resource metadata. When changes are detected it can then run configurable actions for example to run `cfn-init `to restore instance to desired state
* Allows you to update a stack and rerun the meta / bootstrap data effectively.


## ChangeSets
* ChangeSets are similar to doing a `terraform plan` in that it allows you to preview what will change when you apply your changes. 
* Useful to protect yourself from unintended changes eg replacement of a database or EC2 instance which can result in data loss.
* Creates an overview for a stack and then you can apply or discard after reviewing. Applying this will kick off the stack update process.

## Custom Resources
* To be used when cloudformation does not support something natively eg populate an S3 bucket with objects.
* For example your CF stack sends an event to an endpoint to pass some stack data. This could be a Lambda or SNS topic. Your Lambda function is then invoked, does its custom thing eg upload objects to S3. Sends a `responseURL` back to cloudformation stack to say success or fail. If you delete the stack the process is run backwards to undo what your custom resource has done.

In CF a custom resource will look something like:
```
Resources:
  copyanimalpics:
    Type: "Custom::S3Objects"
    Properties:
      ServiceToken: !GetAtt CopyS3ObjectsFunction.Arn
      SourceBucket: "cl-randomstuffforlessons"
      SourcePrefix: "customresource"
      Bucket: !Ref animalpics
  CopyS3ObjectsFunction:
    Type: AWS::Lambda::Function
    Properties:
      Description: Copies objects into buckets
      Handler: index.handler
      Runtime: python3.8
      Role: !Ref IAMRole
      Timeout: 120
      Code:
        ZipFile: |
          import os 
          import json
          < Code to perform custom operation where you'll use the properties
          of the custom resource in order to execute what you need. Think of it like
          having a script to do some custom steps >
          ...
```

## Drift Detection
Drift detection helps you see what physical resources from your CF stack that have been changed from outside of the stack. For example You create an EC2 instance with a Read S3 bucket IAM policy attached to it. You or someone else changes that IAM policy to grant additional permissions and remove S3 read rights from the AWS IAM console. Drift detection can let you know what has changed as often if the stack is in the drifted state, you are likely to encounter errors when doing a stack update / delete action.

To fix this you can:
* Manually revert the changes to match the state that CF expects it
* When deleting a stack you can tell CF to retain / skip problem resources 
* Update the CF stack template to:
    * Add a deletion policy under problem resources to not remove any changed physical resources, run template as this will stop CF tracking this resource
    * Apply another template to remove the problem resources
    * Perform import operation to import currently in place physical resources to match the logical resource in the CF stack