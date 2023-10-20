# AWS Developer tools 
* `CodeCommit` - for our repository
* `CodeBuild` - to build the code
* `CodeDeploy` - to deploy our build code
* `CodeArtifact` - to store, publish and share software packages
* `Amazon CodeGuru` - to automate code reviews
* `AWS CodeStar` - manage software delivery in one easy place
* The above services can run effectively together under `AWS CodePipeline`

# CI / CD concepts

## What problems are we trying to solve?
* Want fast, iterative and short release cycles when compared to a waterfall model
* Increase development and release speed (Dev)
* Maintain stable systems (Ops)
* Automate building and deployment to get things to production as quickly and reliably as possible
* Dev and Ops goals tend to oppose each other so the problem we are trying to solve is to find a way to align these.

## What is CI/CD?
* `CI` = Continuous Integration
* `CD` = Continuous Delivery (not to be confused with Continuous Deployment)

## What is difference betrween Continuous Delivery and Continuous Deployment?

*Continuous Delivery* is automating *up to the point of release*, *Continuous Deployment* is a *full automation from end to end including deployment* to production.


# CodeCommit Overview

## What is CodeCommit?
It is an AWS managed service that hosts *private* Git repositories. You can also use git commands to manage the repository and do all the things you expect like git clone / commit / push. AWS will manage the capacity and availability of it etc.

## Why use this?
It is a managed service so you won't have to worry about the servers, capacity, availability etc. Data is also encrypted at transit and at rest via KMS.

## Benefits and features
* Highly available, scaleable and fault tolerant - very key
* No size limit - will increase based on usage automatically
* Integrates nicely with other services such as `CodeBuild`, `CodePipeline`, `CodeDeploy`, `Lambda`, `SNS` for example
* Works with existing Git-based tools
* Use IAM to control access - you can also create cross account policies for access and control.
* Can be monitored with CloudTrail and CloudWatch 
* Stores repositories in S3 and DynamoDB. Encrypted data is stored across multiple redundant facilities. 
* Create upto 1000 repos by default and up to 25,000 by request
* Receive notifications for events impacting your repositories
* Using CodeCommit triggers, you can send SNS notifications and create webhooks. For example trigger a lambda on commit or branch merge. 

## Exam tips
* CodeCommit *is not* the only repository you can use in an AWS Deployment pipeline
* Other repos that can be used include `S3`, `GitHub`, `Github Enterprise` and `Bitbucket`. To use S3 *as a repository* you need to have versioning enabled.
* Study the dropdowns in the web console - helps you see and describe things you may have missed in your studies. Also helps to remember some things you may need if you are creating resources with IaC for example.
* A single file cannot be larger than 2GB



# CodeCommit Repository Actions

## Creating and viewing repositories
Some AWS cli commands you might use with the repository:
* `aws codecommit list-repositories` - to list repositories (assuming you've authenticated to the AWS account with `aws configure` or SSO access / secret keys)
* `aws codecommit create-repository --repository-name <name>` - to create a repository
* `aws codeccommit get-repository --repository-name <name>` - to get details of a repository
* `aws codecommit help `- this will show a full list of commands available or refer to AWS CLI documentation

### Exam tips
* Anything you can run from the command line you can script. Very important for automation
* Commands tend to be very literal eg `create-repository` or `delete-repository` if you are not sure the exact command and using a process of elimination.

### Permissions and access
* You'll need to make sure the user has the correct IAM access to the relevant AWS services
* The user will also need ssh / https credentials generated in order to use the normal git commands to clone, push and pull. This can be done via `IAM`, clicking the user, going to the `Security Credentials` tab and uploading a public ssh key (that matches the users private key) or generating a https username / password combo. You would then configure your `git` config to run your commands against your private instance.

## CodeCommit data security 

* The encryption is handled for us via `KMS`. 
* This is both *in transit* via ssh / https protocols and also *at rest* once it arrives into the AWS repo. 
* If you go into KMS you will see a key for CodeCommit in there. 
* Keys are *by region*
* Will use an AWS managed key (not customer managed key - CMK)

You may also want to restrict your developers or particular users to not be allowed to do particular things like create or delete repositories. You'll be able to do this with `IAM`. You can either apply appropriate `IAM policies`:

* To the user directly
* To a group and add users to the group
* As an IAM role and allow relevant users to assume this role. For example if using SSO you would attach the appropriate policy to the role they would assume.

### Exam tips
* Repositories are encrypted at rest by default
* Data is encrypted in transit via ssh and https

# CodeBuild Overview

## What is CodeBuild?
It is a fully managed continuous integration service that 
* compiles source code, 
* runs tests
* produces software packages ready to deploy 

## Why use CodeBuild?
* Dealing pretty much with just our code, dont have to worry about managing servers
* Charge based on how many operations and how long operations are running. Much like Lambda - charged for what you use. 
* It scales based on usage and our needs
* Prepackaged build environments 
* Output artefacts for S3 for example (if versioning turned on)

## Benefits and features
* Continuous scaling to meet volume. Immediately processes submitted builds so there isn't a queue.
* Charged based on number of minutes a build takes - pay as you go like Lambda
* Integrates nicely with AWS Dev tools such as CodeCommit / CodePipeline.
* You can use CodeBuild as a worker node, for example as a worker for your existing Jenkins server 
* Integrated and access controlled by `IAM`
* Artefacts encrypted by `KMS` customer specific keys
* Has a number of preconfigured build environments - Java, Python, Node.js, Ruby, Go, Android, .NET Core for Linux, and Docker
* Can use your own build environments for example a docker image with the build tools etc you need. CodeBuild will reference the specified ECR repo.
* Build specification is a YAML file similar to `.gitlab-ci.yml` for what you want to run. This is the `buildspec.yml` file stored in the root of your project
* Select compute power and works with Windows and Linux
* Connect AWS CodeCommit, GitHub, GitHub Enterprise, Bitbucket, or Amazon S3 as a source to build from
* Can be monitored via Console, SDK, CLI, APIs and CloudWatch to view detailed info on builds such as start / end time, commit ID
* Receive notifications via SNS about things impacting your builds.
* Integrates with AWS CodePipeline to help automate release process.


## How to access?
* From CLI
* SDK
* Web UI
* AWS CodePipeline as a build or test action in our pipeline.

## Use cases
* Wanting to automatically trigger a build - filter CloudWatch events for successful merges and trigger build when filter matches
* CodeBuild sends logs to CloudWatch logs -> CloudWatch events filters appropriate -> trigger Lambda

## Exam tips
* Must provide CodeBuild with a build project as an input. Can be created with CLI or console 
* If there is any output, this will be output to S3 bucket
* Only need a "build stage" if code artefacts need to be built / packaged 
* `Buildspec` is a collection of build commands and related settings in YAML format that CodeBuild uses to run a build. 
* `buildspec.yml` file stored in the root of your project to provide build instructions
    * `Version 0.1` runs each build command in a separate instance
    * `Version 0.2` runs all build commands in the same instance. Use of 0.2 recommended.
    * Commands run in phases:
        * `Install` - only for installing packages in build environment
        * `pre_build` commands run before building
        * `build` commands run during the builds
        * `post_build` run after the build
    * Example of `buildspec.yml`:
        ``` 
        version: 0.2

        run-as: Linux-user-name
        
        env:
          shell: shell-tag
          variables:
            key: "value"
            key: "value"
          parameter-store:
            key: "value"
            key: "value"
          exported-variables:
            - variable
            - variable
          secrets-manager:
            key: secret-id:json-key:version-stage:version-id
          git-credential-helper: no | yes
        
        proxy:
          upload-artifacts: no | yes
          logs: no | yes
        
        batch:
          fast-fail: false | true
          # build-list:
          # build-matrix:
          # build-graph:
                
        phases:
          install:
            run-as: Linux-user-name
            on-failure: ABORT | CONTINUE
            runtime-versions:
              runtime: version
              runtime: version
            commands:
              - command
              - command
            finally:
              - command
              - command
          pre_build:
            run-as: Linux-user-name
            on-failure: ABORT | CONTINUE
            commands:
              - command
              - command
            finally:
              - command
              - command
          build:
            run-as: Linux-user-name
            on-failure: ABORT | CONTINUE
            commands:
              - command
              - command
            finally:
              - command
              - command
          post_build:
            run-as: Linux-user-name
            on-failure: ABORT | CONTINUE
            commands:
              - command
              - command
            finally:
              - command
              - command
        reports:
          report-group-name-or-arn:
            files:
              - location
              - location
            base-directory: location
            discard-paths: no | yes
            file-format: report-format
        artifacts:
          files:
            - location
            - location
          name: artifact-name
          discard-paths: no | yes
          base-directory: location
          exclude-paths: excluded paths
          enable-symlinks: no | yes
          s3-prefix: prefix
          secondary-artifacts:
            artifactIdentifier:
              files:
                - location
                - location
              name: secondary-artifact-name
              discard-paths: no | yes
              base-directory: location
            artifactIdentifier:
              files:
                - location
                - location
              discard-paths: no | yes
              base-directory: location
        cache:
          paths:
            - path
            - path
        ```
        
# CodeDeploy overview

## What is it?
CodeDeploy is a fully managed deployment service. It automates software deployments to a variety of compute services like EC2, Fargate, Lambda and on-premise stuff.

## Why use it?
Helps to make it easier to rapidly release features, avoid downtime and handles a lot of the complexities in a deployment model. So moves you closer or actually being able to automate software deployments. The service also scales you match your deployment needs.

## Use cases
Developers / DevOps want to continually deploy to different environments while minimising downtime and leverage AWS services to do rolling or blue/green deployments. They also don't want to worry too much about the infrastructure and having to manage that as part of a deployment. Can also be used if wanting to deploy to AWS instances as well as on-premise ones using the same deployment model.

## Benefits and features
* Automated, repeatable deloyments across environments whether deploying to EC2, Fargate, Lambda or on-premise.
    * CodeDeploy uses a file and command based install model - allows you to reuse existing setup code
    * Helps eliminate need for manual steps which are can be prone to human error
    * Increases speed and reliability of software delivery process
    * Can integrate with Auto Scaling groups. CodeDeploy can be notified when a new intance is launched and will automatically perform an application deployment to the instance before it is added to the ELB.
    * For on-premise deployments your instances will need to be able to connect to AWS public endpoints.
* Laucnh and track status od application deployments via console or CLI. Can also create push notifications about your deployments
* Minimise downtime as changes introduced incrementally and track application health along the way based on rules.
    * Can use Rolling and Blue/Green update deployment models. Mainly to EC2, ECS or Lambda.
    * CodeDeploy will stop your deployment if too many updates have failed via Deployment Health Tracking.
    * You can stop a deployment via console, cli or SDK. You can then also decide to continue or roll back to a previous version.
* Centralised control and monitoring
    * Launch, control and monitor via console, cli, sdk or APIs.
    * If failure occurs, you're able to find the script that failed
    * Set push notifications to update you on status of deployment eg via SMS or SNS
    * Using deploy your application to groups using Deployment groups. So for example deploy an app to more than one deployment group if needed. Test in staging or UAT and then deploy the exact same settigs to your production environment
    * Track deployment history - you can see what app & version is deployed where as well as get a detailed via of successes and errors.
* Platform and language agnostic. Can integrate with your existing software release processes and CI/CD tools such as CodePipeline, Jenkins etc.
    * CodeDeploy uses a single `AppSpec` config file in the root directory of the revision bundle to run actions, tests at each phase of deployment. Commands can be any code or script or program or congiguration tool eg a shell or powershell script, python program etc
    * `AppSpec` can be in YAML or JSON format. This specifies the files to be copied and scripts to be executed.
    * A example of `AppSpec.yml` for an EC2 deployment - `hooks` are basically the scripts to run at each stage. More on that in the exam tips section.
    ```
    version: 0.0
    os: linux
    files:
      - source: Config/config.txt
        destination: /webapps/Config
      - source: source
        destination: /webapps/myApp
    hooks:
      BeforeInstall:
        - location: Scripts/UnzipResourceBundle.sh
        - location: Scripts/UnzipDataBundle.sh
      AfterInstall:
        - location: Scripts/RunResourceTests.sh
          timeout: 180
      ApplicationStart:
        - location: Scripts/RunFunctionalTests.sh
          timeout: 3600
      ValidateService:
        - location: Scripts/MonitorService.sh
          timeout: 3600
          runas: codedeployuser
    ```    

## Exam tips
* CodeDeploy supports the following OS: Amazon Linux, RedHat Enterprise, Ubuntu and Windows server
* CodeDeploy is a building block service. Different use case to Eleastic Beanstalk and OpsWorks which are end to end application managemenht solutions. Remember this to work out the scope of a scenario. If requiring end to end and ease of use including server management, probably not CodeDeploy.
* Deployment configuration details the behaviour for how a deployment should proceed and handle failure.
* By default CodeDeploy will go one instance at a time
* Must specify the following for a deployment
    * `Revision` - *what* to deploy
    * `Deployment group` - *where* to deploy
    * `Deployment configuration` - optional parameter on *what and how* to deploy
* `AppSpec` is used by the AWS CodeDeploy agent. Contains basically the source files to be copied to instances and the (relative) destination folder on the instances.
* `AppSpec` file will be in the root directory of the bundle
* Deployment Life cycle events give you an opportunity to run code as part of the deployment. The order it goes in is
    * `ApplicationStop` - The AppSpec and scripts for this event are from the last successful deployment. You can use this event to shutdown or remove currently installed applications in prep for deployment
    * `DownloadBundle` - Copies revision files to a temp location on instance. Reserved for agents and no user scripts can be run at this time
    * `BeforeInstall` - for preinstall tasks like decrypting files, taking a backup etc
    * `Install` - copies revision files from temp location to final destination folder. Reserved for agent and no user scripts can be run at this time.
    * `AfterInstall` - Used for configuring your app after installation for example
    * `ApplicationStart` - Start application
    * `ValidateService`- Verify everything working as intended.
* You can use your source conrol system to deploy an app. It will need to be bundled in a `.zip`, `.tar`, or `.tar.gz` format.
* If you've just added an EC2 instance to a deployment group, you'll need to deploy the latest version for that instance to get your app. This will not work by default for ASG. You'll need to associate the ASG to a deployment group for this to work with ASG.
    * Newly created ASG instances will be put into `Pending` state until deployment is successful and then be moved to InService once all `checks` complete
* To use CodeDeploy on EC2 instances they must have the CodeDeploy agent installed on them and they *must be able to access the public* S3 and CodeDeploy endpoints
* If wanting to deploy an app across regions, you'll need to copy the application bundle to an S3 bucket in each region and then run your deployments.
* Not charged for deployments to EC2 instances but you are charged if you use this to deploy to your on-premise servers.





