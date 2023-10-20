# Networking

## Virtual Network
* Often called a `VNet`
* Address space is number of IP addresses available - assigned to `VNet`
* Subnets - allow you to segregate the address space. You'd want to do this because:
    * Resource grouping eg splitting development or production traffic
    * Efficient IP address allocation
    * Subnet security - can lock down each subnet with different rules 
* `VNet` belongs to a single region
* Each `VNet` belongs to a single subscription, but a subscription can have multiple VNets
* VNet peering - can pair VNets similar to AWS VPC peering. 
    * Low latency, high bandwidth
    * Links separate networks together as if they were one
    * Transfer data easily between subscriptions and deployment models in separe regions

## Load balancer
* Use anytime you want to distribute traffic from a frontend to a pool of servers in the backend
* Has health probes and rules to determine how / when / where to send traffic 
* Routing based on IP address & port number

## VPN Gateway
* Used to connect Azure resources to on premise devices
* Deploy 2 or more VMs that are deployed to a specific subnet you create called the `gateway subnet`. These VMs are created when you create the VPN Gateway
* Site to site connection form the main compoments
    * VNet with VPN Gateway attached <-> Tunnel for encrypted traffic <-> Gateway on-premises that accepts the encrypted traffic

## Application Gateway
* Route like a load balancer based on HTTP Request eg URI path or host header
* Can scale up or down based on traffic
* End to end encruption for all traffic. Can disable for transfer to backend
* Zone redundancy to make highly available
* Multi-site holting. Use same gateway for upto 100 websites

## Content Delivery Network (CDN)
* A disributed network of servers that can deliver web content close to users
* Copies of your data is replicated to `edge servers`
* Azure benefits include better performance (lower latencies for users), scaling to meet increased traffic, distribution as edge servers closer to end user and caching.

## ExpressRoute
* Super fast, private connection into Azure from on-premises
* Don't go over the public internet