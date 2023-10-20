# CODE* suite / SDLC Automation

## CI / CD concepts

### What problems are we trying to solve?
* Want fast, iterative and short release cycles when compared to a waterfall model
* Increase development and release speed (Dev)
* Maintain stable systems (Ops)
* Automate building and deployment to get things to production as quickly and reliably as possible
* Dev and Ops goals tend to oppose each other so the problem we are trying to solve is to find a way to align these.

### What is CI/CD?
* `CI` = Continuous Integration
* `CD` = Continuous Delivery (not to be confused with Continuous Deployment)

### What is difference betrween Continuous Delivery and Continuous Deployment?

* **Continuous Delivery** is automating **up to the point of release**
* **Continuous Deployment** is a **full automation from end to end including deployment** to production.

## CodeCommit 

### Overview

* AWS managed service that hosts **private** Git repositories. 
* You don't have to worry about the servers, capacity, availability etc. Data is also encrypted at transit and at rest via KMS.
* Highly available, scaleable and fault tolerant - very key
* No size limit - will increase based on usage automatically
* Integrates nicely with other services such as `CodeBuild`, `CodePipeline`, `CodeDeploy`, `Lambda`, `SNS` for example
* Works with existing Git-based tools
* Use IAM to control access - you can also create cross account policies for access and control.
    * SSH / HTTPS credentials created on a per user basis, similar to access keys
* Can be monitored with CloudTrail and CloudWatch 
* Stores repositories in S3 and DynamoDB. Encrypted data is stored across multiple redundant facilities. 
* Create upto 1000 repos by default and up to 25,000 by request
* Receive notifications for events impacting your repositories
* Using CodeCommit triggers, you can send SNS notifications and create webhooks. For example trigger a lambda on commit or branch merge. 
* Data is encrypted via `KMS`
    * Repos are encrypted at rest by default
    * Both **in transit** via ssh / https protocols and also **at rest** once it arrives into the AWS repo. 
    * Keys are **by region**
    * Will use AWS Managed key

### Creating and viewing repositories via cli

Some AWS cli commands you might use with the repository:
* `aws codecommit list-repositories` - to list repositories (assuming you've authenticated to the AWS account with `aws configure` or SSO access / secret keys)
* `aws codecommit create-repository --repository-name <name>` - to create a repository
* `aws codeccommit get-repository --repository-name <name>` - to get details of a repository
* `aws codecommit help `- this will show a full list of commands available or refer to AWS CLI documentation

### Exam tips
* CodeCommit *is not* the only repository you can use in an AWS Deployment pipeline
* Other repos that can be used include `S3`, `GitHub`, `Github Enterprise` and `Bitbucket`. 
    * To use S3 *as a repository* you need to have versioning enabled.
* Study the dropdowns in the web console - helps you see and describe things you may have missed in your studies. Also helps to remember some things you may need if you are creating resources with IaC for example.
* A single file cannot be larger than 2GB
* Anything you can run from the command line you can script. Very important for automation
* Commands tend to be very literal eg `create-repository` or `delete-repository` if you are not sure the exact command and using a process of elimination.

## CodePipeline
* Is the glue that makes all the other code* work toegther
* A **continuous delivery** tool
* Controls **flow** from **source** through to **build** and **deployment**
* Pipelines built from stages
* **STAGES** are sequential or parallel **actions**
* Movememnt between stages can require manual approval
* Artifacts can be loaded into an action and generated from an action
* State changes -> generate events into EventBridge that can be used by any consumer
* Can interact with cloudtrail or console UI
