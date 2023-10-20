# Elastic Beanstalk

## Architecture and components
* A Platform as a service (PaaS) - you provide some code, select some options and AWS provide the infrastructure around it.
* Developer focused - not the end user
* High level managed application environments
* User provides code, EB handles the environment
* Focus on code, low infrastructure overhead
* Great for small development teams
* Uses cloudformation to build the EB infrastructure. You can find the stacks linked to your application / environment there.
* **How it this different from CF?** With CF you have to design, write and manage it for the full stack. *CF is infrastructure as code*. EB means you don't have to have much knowledge or thought around the infrastructure. For example if using in a test environmenmt and a developer just wants to get an application up to see if it works as intended. Upload code to beanstalk, select some basic options and AWS does the provisioning. PaaS. Main purpose is to remove the requirement to manage infrastructure.
* Fully customizable as it uses AWS products behind the scenes.
* Doesn't come free - requires application support. So a developer would need to make sure code works / fits for beanstalk.
* Supports a number of languages / platforms. Come under some main categories
    * Built in languages (things like Python, Ruby, Javascript, Node.JS, Go, .NET Core / .NET for windows, PHP )
    * docker (single or multicontainer and also preconfigured docker) - uses ECS behind the scenes
    * custom platforms (packer)
* You can create databases from within Beanstalk however this does come with a risk.
    * DB in environment will be lost if the environment is deleted. Might be worth considering create a DB outside of Beanstalk and pointing your application code to that DB to avoid this issue. Especially useful if doing things like Blue/Green deployments.

### Terms
* `Elastic Beanstalk Application` - it isn't code. It is a collection of thing related to an application. Think of it like a helm deployment might have a Deployment, Ingress & PVC as part of a single `helm install <application>` command. Conceptually a container or folder containing everything linked.
* `Application versions` - specific labeled versions of deployable code for an application. Think the `image` version on a helm deployment manifest. If you see the term `source bundle` it is likely to be referring to application versions in Beanstalk. These are stored in S3
* `Environments` - sub containers within the EB application. It is within these environments that you would deploy a `specific application version`. Environments are containers of infrastructure and configuration for the specific `application version`
    * Each environment is either a `web server tier` or a `worker tier`. This difference controls the function and structure of the environment.
    * `web server tier` - designed to communicate with end users. Scales based on incoming requests from the LB
    * `worker tiers` - designed process work in some way from the web tiers. Scale based on queued messages from SQS
    * Both have Autoscaling groups. So for example a process might be receive info from the web tier, put into an SQS queue which is then processed by/in the worker tier
    * Each environment has it's own DNS CNAME. You can connect to specific environment via this CNAME.

## Deployment Policies

aka `Deployment Types`. How `application versions` are deployed to environments. The different types are:
* `All at once` - Deploy all at once, brief outage. Ideal during development when downtime is acceptable
* `Rolling` - Deploy in batches. For example if you have 10 servers, you can set to deploy 2 at a time. Useful if you can't afford full downtime. Reduced capacity while upgrades being done.
* `Rolling with additional batch` - Same as above but a new batch is provivioned to maintain capacity. Better for real environments with real load.
* `Immutable` - new instances with new version running. Once health checks passed it will but over to instances on the new version
* `Traffic splitting` - Fresh instances with traffic split. Sort of like a canary deployment? You can control the distribution across the 2 versions. Comes at additional cost.

## Decoupling RDS created within an existing Beanstalk environment
* Create RDS Snapshot
* Enable `Deletion Protection`
* Create a new EB environment with samre app version
* Make sure new environment can connect to the DB
* Swap environments via CNAME or DNS entry
* Terminate old environment - will try to delete RDS instance but will fail due to delete protection
* Localed `DELETE_FAILED` stack, manually detaila nd select `retain stuck resources`

## Customizing via .ebextensions
* Inside the application source bundle (ZIP/WAR) you will create a `.ebextensions` folder. From here you add your `YAML` or `JSON` files ending in `.config` for them to be recognised as an extension.
* Uses cloudformation format to create additional resources within the environment
* Files can contain `option_settings` which allows you to set the options of resources or `Resources` to create new resources. For example you may also wannt to create an Elasticache instance.
* You can also customise and add things liek packages, sources, files, users, groups, commmands, container_commands, services etc which are inside the `.config` files

## Environment cloning
You may want to do this if for example you're cloning your production environment into a new Test / QA environment so make sure it is like for like.
* Benefits from copying all the configuration elements over for you.
* Will also copy any RDS inside the environment but will **not copy data**
* Can only clone environment to a different platform version of the same platform branch. A different platform branch isn't guaranteed to be compatible.
* Does not clone any `unmanaged changes` - basically anything done outside of the EB console / cli / api
