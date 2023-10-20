# Lambda, Serverless & Application Services

## CloudWatchEvents and EventBridge

### What is it?
Delivers a near real time stream of system events and describe changes in AWS services. For example if an EC2 instance is started or stopped, it will create a CloudWatchEvent. EventBridge is replacing CloudWatchEvents as well as being able to handle events from third parties or custom applications.

### Key Concepts
* If `x` happens or at `y` times then do `z`.
    * `x` being an event eg EC2 instance stopped - also known as the `producer`
    * `y` being a time eg CRON format so 'every 6 hours'
    * `z` being a target to deliver the event to. For example if EC2 instance stopped, send event to AWS SNS
* Have a default event bus - basically a stream of events
    * In EventBridge you can have additional event buses
* Create rules that match events or schedules and sends that to 'one or more' targets
* Events are in a JSON structure
* The target receives this event JSON to do with as you need
    * For example an instance stopped event might contain instance name, time stopped, reason change was initiated etc
    * We define a target to be a Lambda
    * We may write code in that Lambda to filter the event to extract the instance name, time stopped and reason change was initiated

## Lambda

### Key concepts

* Lambda is a 'Function as a service" (FaaS) - short running and focussed
* A piece of code which is what runs
* Functions use a `runtime` - for example Python 3.8
* Fucntions are loaded and run in the runtime environment
* Has a direct memory allocation. CPU is indirectly allocated based on amount of memory
    * `128MB` to `10240MB` in 1MB steps.
    * `1769MB` works out to `1vCPU` and scales in a linear fashion
* Also allocatres storage space mounted at `/tmp` and defaults to `512MB` but can scale to `10240MB`
* Can run for upto `900 seconds` aka `15 mins`
* Billed for the duration that the function runs for per invocation
* Key part of `serverless architectures`.
* Supports lots of different run times such as `Python`, `Ruby`, `Java`, `Go`, `C#` and `NodeJS`
* Custom runtimes can be created for Lambda using the `Lambda layer` functionality
* Lambda environments have `no state` - imagine being inside a brand new environment and this is wiped when the function finishes.
* Controlled by `execution roles` which are basically `IAM roles`

### Common uses
* Serverless Applications (S3, API Gateway, Lambda)
* File processing (S3, S3 Events, Lambda)
* Database Triggers (DynamoDB, DynamoDB Streams, Lambda)
* Serverless CRON (EventBridge + Lambda)
* Realtime stream data processing (Kinesis + Lambda)

### Networking modes
There are two networking modes in AWS Lambda, `public` which is the default and `vpc networking`.

#### Public
* Starts with an AWS environment and has a single Lambda function, which is part of a wider environment and running in the public environment
    * This means it can access public aws services and the public internet - eg SQS and DynamoDB or IMDB if the function wanted to fetch information from a website
* Offers best performance as no customer specific VPC networking is required
* BUT this also means those Lambda functions have **no access to VPC based services** UNLESS the are configured with public endpoints + security controls that allow external access.

#### VPC networking
* Configured to run inside a private subnet
* Obey all the same VPC networking rules because running within that VPC.
    * Can freely access other VPC based resources assuming network ACLs / security groups allow that access
    * Can't access things outside the VPC unless network rules allow 
* Ways to access public things from Lambda with VPC networking:
    * You could use `VPC Endpoints` as a way to provide access to public AWS services
    * A `NAT Gateway` to a subnet that has an `Internet Gateway` attached to it
* Lambda execution role must also have `ec2 network permissions` to the `execution role` to do so.
    * This is because in VPC networking mode, an ENI is created that connects your VPC to AWS Lambda service VPC so that traffic can pass through
    * This allows the Lambda to work **at scale** with each unique combination of subnet and security group rules
    * ENI is created once and can take up to 90 seconds on the first invocation and also after network rules are updated

### Security
* An `execution role` is attached to a running AWS Lambda
    * That `execution role` has an IAM role attached to it with a `trust policy` that allows Lambda to assume that role, and the permissions that role grants temporary credentials that the Lambda function uses to access other AWS services. 
* Also has `resource policies` - this controls **what** services and accounts can **invoke** Lambda functions.
    * Can allow external accounts to invoke the functions
    * Can be changed via CLI or API, currently can't be changed via the console UI.
* There is a **pre-built** AWS policy and IAM role that allows Lambda to  basic permissions they need to log info into CW logs.

### Logging
* Lambda uses `CloudWatch`, `CloudWatch Logs` and `X-ray`
    * Outputs of functions go to `CloudWatch Logs` - will need to grant permissions to the `execution role` in order to log
    * Metrics to `CloudWatch`
    * You can integrate Lambda with `-X-ray` to gain `distributed tracing` capabilities. Useful if trying to track what is going on with a serverless app / workflow

### Invocations

#### Synchronous
* CLI / API invokes a lambda function, passing data and waits for a response
* Lmbda function responds with data or fails
* Also happens if used with API Gateway
* Errors or retries have to be handled within the client

#### Asynchronous
* Typically when AWS services invoke lamba functions on your behalf
* Basically doesn't continue waiting once the Lambda is invoked. 
* Example S3 PUT event might invoke a Lambda to do something in DynamoDB. Once the Lambda is invoked, S3 does not wait for a response.
* Lambda is responsible for any reprocessing. Configurable between `0` and `2` times
    * Function code needs to be **idempotent** - basically means the same outcome should happen when it is run.
* Can configure Lambda to send results to another configurable destination based on success or failure.
    * For example send events to a dead letter queue after multiple failures
    * Send events to SNS / SQS / Lambda / EventBridge where successful or failed event

#### Event Source Mapping
* Used on streams / queues which don't support event generation for example `Kinesis`, `DynamoDB` streams, `SQS`, Amazon managed Apache Kafka
* Event source mapping will read from the queue or stream in batches -> passes this to lambda to process each batch
* Permissions from the lambda `execution role` are used by event source mapping to interact with the event source. So it is important that the IAM role has permissions to do so. Event source mapping uses the permissions on the `execution role` on behalf of the Lambda to interact with the intended event source
    * For example the Lambda execution role must have permissions to access to Kinesis Data Stream to grab data

### Lambda versions
* Lambda functions have versions eg `v1`, `v2`, `v3` etc
* Version is the `code` plus `configuration` of the lambda function
* Unpubliushed functions can be changed & deployed
* Version is `immutable` once it is published. It has its own ARN - a `qualified ARN`
* `$Latest` points to the latest version - not immutable as latest version will change with each new iteration - has an `Unqualified ARN` - not a specific version other than latest
* If you don't specify a version, you are using the latest version
* You can also create `aliases` to point to specific versions

### Lambda Aliases
* An alias is a pointer to a function version
    * `PROD` -> mylambda:1
    * `DEV` -> mylambda:4
* Have a fixed an unique ARN 
* Static - meaning the alias can only point at 1 version at a time
* Alias can be changed to reference different version
* Useful for PROD/DEV, BLUE/GREEN, A/B testing
* Can form part of a normal CI/CD process
* `Alias routing` - sending a percent of traffic to different versions

### Lambda environment variables
* A key / value pair (0 or more)
* Default associated with `$LATEST`
* If you publish a version with environment variables set - they become fixed / immutable within that version


### Lambda startup times
* Runs inside an `execution context` - think a kubernetes container where its allocated a set amount of resources
* Process: Environment is created -> any runtimes required downloaded / installed -> deployment package downloaded -> function executes
    * known as a `cold start`
    * ~ 100ms
* If function is executed again without too big a time gap, it may use the same context that was previously used
    * known as a `warm start` and will be significantly quicker as the prerequisites have already been setup
    * ~ 1-2ms
* If you need 20 concurrent executions then you may have 20 'cold starts'.
* Can improve performance of cold starts if you use `Provisioned concurrency` where AWS will keep X number of contexts available so you'll have warm starts on those
    * Useful for known periods of high concurrency, new release of a serverless application
* Can also use the `/tmp` space to predownload relevant data.

### Lambda function handler architecture and overview
* Phases are such as:
    * `INIT` - creates or unfreezes the execution environment / context
    * `INVOKE` - runs the function handler (cold start if fresh and with some lag). The next invoke if done fairly quickly since the first will be quicker (warm start) as it uses the same environment / context
    * `SHUTDOWN` - terminates the environment / context. This means there will be a `cold start` the next time the function is run.

A well designed Lmabda should:
* Assume there will be a cold start everytime but also to make use of warm starts

Inside the `INIT` phase you have the `extension init`, `runtime init` and `function init`
* Run once only and not during every invocation
* Put anything that might be reused in the function init area. For example connection to a DB

In between the INIT and SHUTDOWN phase you have the lambda `INVOKE` running. Basically if in pythong will be the code under `def lambda_handler(event, context):`
* Run every invocation

Inside the`SHUTDOWN` phase has the `runtime shutdown` and `extension shutdown`.

### Monitoring, logging and tracing Lambda based apps
* Metric data for Lambda is pumped into CloudWatch or directly via the monitoring tab of the specific function
* Logs (execution logs) are sent through to CloudWatch Logs
    * anything in `stdout` or `stderr` will be captured
* Log groups go by the name `/aws/lambda/<functionname>`
* Log stream by the format `YYYY/MM/DD/[ $LATEST || version ]..random`
* Tracing can be done via `X-Ray`
    * Need to enable `Active Tracing` on a function
    * Can be enabled via cli with `aws lambda update-function-configuration --functon-name <name> --tracing-config Mode=Active`
    * Need to provide permissions to X-Ray in your lambda execution role. The managed policy `AWSXRayDaemonWriteAccess` grants this.
    * Then use the X-Ray SDK within your function
    * The environment variable `AWS_XRAY_DAEMON_ADDRESS` provides connection details including port for the X-Ray daemon.

### Lambda layers
* Layers can be used in separate functions. So for example you may make a layer that has your shared libraries that multiple functions may use. May be importing large python libraries. Think of it similar to a base layer in Dockerfile that you can build from.
* You can use `AWS` created ones, `Third party` created ones or `custom` ones that you can make yourself.

### Lambda container images
* Main use cases:
    * In an Orgs CI/CD process where they use their own containers
    * Locally test lambda functions before deployment
* To do so you must include the Lambda Runtime API inside your container image
* You can also use the Lambda Runtime Interface Emulator (RIE) to be able to test locally. 

### Lambda and ALB integration
You can interact with Lambdas from an ALB (application load balancer)
* Flow 
    * Client makes http/https request to ALB ->
    * ALB configured with target group pointing at a lambda. This executes synchronously (waits for a response). JSON event is passed through between ALB and Lambda. ALB translates HTTP/s to JSON when passing to lambda, and translates from JSON to HTTP/s response back to client
    * Client would likely be unaware lambda was involved
* Multi-value headers -> If not using `multi value headers`, the lambda only receives the the last value sent by the client
    * example if `http://website.com/?&search=fish&search=frog` lambda would only see `"search": "frog"` without multi value headers under `"queryStringParameters"`
    * With multi value headers with the same query, lambda would see an array in the JSON such as `"search": ["fish", "frog"]` under `"multiValueQueryStringParameters"`

### Lambda resource policies
* Resource policy describes **WHO** can do **WHAT** with the lambda function. This is different to the execution role which determines **WHAT** the Lambda function can do.
* Often doesn't need to be changed so don't often interact with
* Used in times when you need to access resources from one account to another account. Think a Lambda triggered from one account that 
* Cross account requires identity **OUT** from source account **AND** resource policy **IN** to destination account
* Default policy is empty -> only has the implicit trust of the account the source lambda is running in.
* When you configure for example S3 bucket events to trigger a Lambda, behind the scenes the permission is added to the resource policy that allows S3 to invoke the lambda function. This is because S3 cannot assume the role to get the permission.
* Use cases:
    * Used when services cannot can't assume a role eg S3
    * Required for cross-account (lambda has no trust)
    * Not required for an identity in the same account
* You can view and perform some edits from the UI but fully from the CLI/API

## API Gateway

### Overview
* A service which lets you create and manage APIs.
* Great in serverless architectures 
* Sits between **applications** and **integrations** (services)
* Highly available, scalable, hands auth, onfigurable throttling, caching, CORS, transormations, OpenAPI spec, direct integration with AWS services eg Lambda, DynamoDB, SNS, Stepfunctions, HTTP endpoints
* A public service
* Can connect to services / endpoints in AWS or on premisis
* HTTP, REST and WebSocket APIs
* 3 phases
    * Request -> when it receives a request (authoriuses, validates and transforms request in a way integration can handle)
    * Integrations -> when it is pushed to the backend service / application eg Lambda / SNS / DynamoDB 
    * Reponse -> when response provided back to the client (transforms, prepared and return response)
* CloudWatch logs can store and manage full stage request and response logs. Cloudwatch can store metrics
* API Gateway cache can be used to reduce calls made to backend

#### Authentication methods
* No auth (completely open)
* Cognito user pools
* Lambda based auth (used to be called custom auth)
* Can pass in auth details in the header of a request

#### Endpoint types
* Edge optimized - any incoming requests are routed to the nearest cloudfront POP (point of presence)
* Regional - when clients in the same region - suitable when users or AWS resources in the same region
* Private - only accessible within a VPC via interface endpoint

#### Stages
* APIs are deployed to stages and each stage has one deploment. For example a `prod` stage and a `dev` stage.
* Each stage has its own endpoint URL and settings.
* Each stage can be deployed onto individually so you might have V1 lambda in your `prod` stage but have V2 in your `dev` stage
* Can enable canary deployments to stages

#### Errors
* `4XX` - Client errors. Invalid request from the client side.
    * `400` - Bad request - very generic
    * `403` - Access denied or request filtered
    * `429` - Throttlign is occurring on API Gateway
* `5XX` - Server side errors. Valid request, but backend issue.
    * `502` - Bad gateway exception. Bad output returned by Lambda
    * `503` - service unavailale. Backend is unavailable or having issues
    * `504` - Integration failure. 29s limit for any requests for API gateway. So if using Lambda, the function must complete within this time even if the lambda has a longer timeout

#### Caching
* Caching is configured per stage
* Without cache, all requests are passed through to the backend integrations
* With caching it can be configured for
    * Cachce size of `500MB` to `237GB`
    * Default TTL is `300` seconds. Confifgurable time of min `0` to max `3600s`
    * **Can be encrypted** - important to remember for the exam
* Benefits are reduced load / cost when using backend services as likely charged by number of requests. As well as improved performance (speed of response)

### Methods and Resources
* `https://url/stage/resource` - this is the general structure of the invoke URL.
* Resources can be thought of as points in the API tree or bits of functionality eg `/dev/listevents`
* Methods are the desired action using HTTP verbs eg GET, PUT, DELETE etc
    * example `/dev/listevents` would have a `GET` method pointing at a Lambda that might query a DB to get list of events to return
* Flow is something like: **METHOD REQUEST** -> API gateway transforms -> **INTEGRATION REQUEST** -> **INTEGRATION RESPONSE** -> API Gateway transforms -> **METHOD RESPONSE**

### Integrations aka backend services
* If you hear `proxy` then it means passing the data straight through without API gateway doing any transformations
* Different types of integrations:
    * `MOCK` - used fort testing, no backend involvement
    * `HTTP` - backend HTTP endpoints in the backend. AKA HTTP custom integration. Have to configure both integration request and integration response (mapping templates)
    * `HTTP Proxy` - pass through data unmodified and also returned to client unmodified - no mapping templates used.
    * `AWS` - lets an API to expose AWS services. Need to setup mappings in each direction for translations
    * `AWS_PROXY` (Lambda) - Low admin overhead Lambda endpoint - function is responsible for formats

#### Mapping templates
* Used for `AWS` and `HTTP` integrations
* Allows you to **modify** and **rename** parameters
* Modify the **body** or **headers** of a request
* **Filtering** - remove anything that isn't needed
* Uses Velocity Template Language (**VTL**)
* Common exam scenario -> REST API on API Gateway to SOAP API

### Stages and deployments
* Like Lambda, when you make changes it needs to be published / deployed before it is actually in use
* Each one has its own configuration, but they are not immutable
* You can use stage variables

### Swagger and OpenAPI
* OpenAPI was formally known as swagger. Swagger was basically v2, OpenAPI v3.
* Basically a standard for REST APIs to describe what it is, how to use etc
* Defines endpoints and operations, input and output parameters and auth methods
* Contains non tech info eg licenses, terms of use, contact info etc
* API Gateway is capable of exporting to Swagger/OpenAPI and importing from them

## SNS (Simple Notification Service)

### Overview
* Highly available, scalable (region), durable, secure, publish / subscribe service
* AWS public service - nbetwork connectivity via a public endpoint
* Coordinates sending and delivery of messages
* Messages are `<= 256KB` payloads
* **SNS topics** are the base of SNS - this has most of the permissions and configuration
* **Publushers** send message to a **topic**
* **Topics** have **subscribers** which **receive** messages
* Subscribers can be for example HTTP/s, Email, JSON, SQS, MObile push, SMS messaghes and Lambda
* SNS is used across AWS for notifications eg CloudWatch and Cloudformation
* Offers **delivery status** - such as HTTP/s, Lambda and SQS
* Offers **delivery retries** - reliable delivery
* Capable of Server Side Encryption (SSE)
* Can be used cross-account via **TOPIC POLICY** (similar to resource policy for lambda)

## SQS (Simple Queue Service)

### Overview / architecture
* An AWS Managed service for message queues
* Public service
* Billed on requests
    * 1 request = 1-10 messages upto 64kb in total
* Short and long polling
    * Short - immediate - not cost effective if queues are empty 
    * Long (waitTimeSeconds) - up to 20 seconds until messages arrive on the queue before returning the request. Probably how you should poll SQS as it uses fewer reqeusts 
* **Highly available** by default - don't need to worry about resiliency or replication
* Queues are either **Standard** or **FIFO** (first in, first out)
    * FIFO **guarantees** an order in messages
        * exactly-once delivery guaranteed
        * Dont' offer exceptional levels of scaling (performance). **3000 messages per second** with batching, up to **300 messages per second** without
    * Standard is **best effort** so possibility messages will be received out of order
        * at least once delivery
        * Scale to near infinite level
* Up to `256KB` in size - need link for larger data
* Messages can live up to **14 days**
* Supports encryption at rest (KMS) and in-transit
* Identity policy (same account) or queue policy (can allow for external accounts) can be used to control access to the queue
* Received messages are **hidden** (visibility timeout) - clients that consume messages need to explicitly delete the message otherwise it may reappear in the queue after the timeout has passed.
    * **Default** is 30s
    * Can be configured between **0s** and **12 hours**
    * Set on **queue** or per **message**
* Also concept of **dead-letter queue** - problem messages can be moved to this queue
    * Allows you to do different styles of processing
* Used to **decouple** applications
* ASG can scale or Lambdas invoked based on queue length - allows complex worker pool style architectures
* Example scenario of use:
    * Client uploads file to web app -> web app is under an ASG that scales in / out based on CPU -> Uploads file to S3 bucket which generates a CW event + publish to an SQS queue
    * Another worker pool in another ASG (scale on SQS queue length) will read from this queue and process message
    * If using a **fanout** architecture you might have similar to above but instead of publish message to SQS queue, publish to an SNS topic -> Have 2 or more SQS queues subscribing to this topic -> A separate worker pool her SQS queue to read and process messages from each SQS queue.

### FIFO vs Standard
* FIFO is sort of single lane highway, standard is multi-lane highway to give a visualisation of how much traffic can pass through at a time
* FIFO is 300 TPS (transactions per second) without batching, 3000 TPD with
    * There is also a high throughput mode in FIFO
* Standard - scalable, near unlimited TPS
* Using FIFO over standatd is basically trading performance for the preserved order and "exactly once processing" - no duplicate messaging
* FIFO queues require a FIFO suffix to be valid - exam tip to pay attention to.
* FIFO ideal for anything that needs to be processed in order 
* Standard queues are ideal for decoupling worker pools, batching for future processing

### SQS extended client library
* You may want to use this when handling messages over SQS max of **256KB**
* Allows you to process large payloads - bulk of it stored in S3
* Works by SendMessage -> uploads the bigger payload to S3 an in the message stores a link to that payload -> When receive message the client will load the payload from S3 to have the contents of it
* When you delete the message you also delete the S3 data
* Works for messages up to 2GB in size
* Basically handles the integration data behind the scenes
* Exam often mentions java with the extended client library

### SQS Delay Queues
* Allows you to pause delivery of message to consumers, effectively start in hidden
* Done via the `DelaySeconds` command
* If consumer polls queue during this time - it will show no messages received until this time is done. Then it can be received and processed.
* **Default** is `0`, **max** is `15mins`
* Can be configured on a per message basis
* Different from Visibility timeout as that needs to appear on queue and is only hidden after a client consumes that message
* Not supported on FIFO queues

### SQS Dead-Letter Queues
* Help you handle reoccuring failures while continuing to process your normal SQS messages
* Define a redrive policy - this specifies the source queue, the dead letter queue and conditions where messages will be moved to the dead letter queue. You define a `maxReceivedCount`
    * Each time a message is received in the queue it is assigned a property `ReceiveCount` - so the same message keeps appearing this count increases each time.
    * After it is more than the maxReceiveCount and isn't deleted - it is moved to the DLQ
* Allows for separate diagnostics to work out what is causing the issue
* Retention set on the DLQ should be longer than the SQS queue as it looks at the timestamp it was first added to SQS, rather than the time moved to DLQ

## Step Functions
Used for long-running serverless workflows. `Start` -> `STATES` -> `END`
* Allow you to create **state machines**
* Something occurs at each state. Allows for decision trees to be made. Think about ordering something from a website. States might be like confirm order details, process in factory, package order, send to courier, courier delivers order.
* **Maximum** duration of **1 year**
* **Standard** Workflow (Default, 1 year execution limit) and **Express** (high volume event workflows, run for max of 5 mins) workflow
* Started via API Gateway, IOT Rules, EventBridge, Lambda can execute state machines 
* Using Amazon States Language (ASL) - JSON template
* IAM Roles are used for permissions to interact with other AWS services

### States
* **SUCCESS** & **FAIL**
* **WAIT** - Wait for period of time or wait until a specific date / time. Pauses the processing of the state machine workflow until the duration has passed or timestamp has arrived
* **CHOICE** - Allows state machine to take a different path depending on input
* **PARALLEL** - Allows parallel branches in the state. So basically execute them at the same time
* **MAP** - Accepts a list of things, basically does a `for each` item, do X
* **TASK** - A single unit of work performed by a state machine. Allows you to perform actions eg via Lambda, batch, DynamoDB, ECS,SNS, SQS, GLUE, SageMaker, EMR, Step Functions
