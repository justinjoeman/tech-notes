# Azure architecture

## Regions
A set of datacentres in a latency defined perimeter in a regional low latency network. 

You should choose a region based on
* Closest to where your users are (latency)
* Some features aren't available in all regions (features)
* Pricing varies per regions (prices)

* Each region is paired
* Helps with outages failover, primary region outage can failover to secondary region
* Useful for planned outages
* Services can be replicated to paired regions

## Availability zones
* Unique physical location within a region
* Each zone has own power, cooling and networking
* Each region has minimum of 3 zones

## Resource groups
* Everything is inside a resource ghroup - no exceptions
* Think of it as a container for Azure resources
* Each resource can exist in a single resource group - no exception
* You can add / remove resources to any resource group at any time
* You can move from one group to another
* Resources from multiple regions can be in one resource group
* Manage access control
* Can interact with resources in other resource groups
* Resource groups myst have a location or region as it stores meta data abut resources within it 

## Azure Resource Manager (ARM)
* All interactions (console, cli, SDK etc) with resources go through the ARM API.
* Benefits include
    * Group resource handling eg deploy, manage, monitor per group
    * Consistency from various tools will result in the same consistent state
    * Define dependencies between resources
    * Access contorl - built in features 
    * Tagging resources
    * Billing 