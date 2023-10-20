# OpsWorks

## Overview

* Requires knowledge of Chef / Puppet to get the most out of it
    * If using Chef or Puppet then OpsWorks is a good solution in order to have your configuration within AWS
* A configuration managed service that helps you configure and operate applications in AWS when you use Puppet or Chef
* Where does it fit?
    * **CloudFormation** gives most control at a higher admin overhead
    * **OpsWorks** offers **less** control/admin overhead than CF but **more** control than Elastic Beanstalk at a greater admin overhead
    * **Elastic** Beanstalk ovvers the least control / admin overhead to the other services.
* Functions in 1 of 3 modes
    * **Puppet Enterprise** - Create an AWS managed puppet master server
    * **Chef Automate** - create AWS maanged chef servers. Similar to IaC
    * **OpsWorks** - an AWS integrated Chef. No servers to manage
* OpsWorks tends to be more useful for Infratructure Engineers and Elastic Beanstalk more useful for development teams

## Key components of OpsWorks

* **Stacks** - Core component of OpsWorks. A container of resources that share a similar function. Similar to a CF stack
* **Layers** - each layer is a specific function within a stack eg a layer for servers, another layer for load balancer and a layer for DB etc
* **Recipes / Cookbooks** - generally applied to a layers. As once a recipe is applied to a layer, it'll replicate those changes out to all the things in that layer. 
    * Cookbooks are a collection of recipes that can be stored on Github (something to look out for in exam)
* **Lifecycle events** - Setup, Configure, Deploy, Undeploy and Shutdown
* **Instances** - compute managed by OpsWorks. Can use EC2 instances and om-premise servers. Supports auto-healing. 3 modes:
    * `24/7 based` - always on
    * `Time-based` (stop start based on a known schedule)
    * `Load -based` - turn on or off based on metrics, like an ASG
* **Apps** - Store apps and related files in a repo such as an `S3 bucket`. Each app is represented by an opswork app that has type and other info needed to deploy app from repository to instance. Things such as repo url and password.
    * When OpsWork app is deployed, it triggers the `deploy event` that runs the deploy recipes on any applicable instance
