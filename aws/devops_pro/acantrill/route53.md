# Route 53

## Fundamentals
* AWS Managed DNS product
* Can be used to register domains (domain registrar) and host zone (domain hosting) files on managed nameservers
* Global service with a single database
* Globally resilient - can tolerate failure of 1 or more regions and still operate
* Usually 4 nameservers per DNS hosted zone
* Hosted zone - can be public (anyone on internet) or private (linked to 1 or more VPC and only acessible from those VPC)

## DNS record types
* Nameserver (NS) records - allows DNS delegation. Kind of like a pointer to say "those servers over there host the record you're after"
* **A** and **AAAA** Records - map hostnames to IP address. 
    * **A** -> ipv4
    * **AAAA** -> ipv6
* **CNAME** - Basically an alias. Host to host record. eg CNAME www.com -> A record server-a.com
* **MX Record** - used for email. Contain a priority and a value. Lower values = higher priority
    * `MX 10 mail` - this would assume the email server is the mail record in the same DNS zone
    * `MX 20 mail.anotherdomain.com` - this would be a FQDN and say the email server is in another location and zone
* **TXT** - add text to a domain to provide additoonal functionality eg prove domain ownership.

## CNAME vs R53 Alias
* An `ALIAS` record maps a name to an AWS Resource
* Can be used **both** for the naked/`apex` (google.com) and normal records (docs.google.com)
* For non apex - functions like a CNAME
* `TYPE` should be the same as the record it is pointing at eg pointing an alias to an ELB A record, you'd use an alias of type `A`.
* Can only use alias if route53 is hosting your domains
* **EXAM TIP** - For AWS services, default to using an ALIAS

## Simple routing
* Allows you to create 1 record per name eg www.domain.com
* Values can be single or multi-value eg www.domain.com -> 1.1.1.1 OR 1.1.1.1, 1.1.1.2, 1.1.1.3
* Doesn't support health checks
* Use when you want to route traffic to one service such as a web server

## R53 health checks
* Separate from, but are used by records. Configured outside of the recordset
* Health checkers are located globally
* Not limited to only AWS targets
* Checks occur every 30s by default. Or every 10s with additional cost
* Types of checks:
    * `TCP` - Tries to establish TCP connection with endpoint and `needs to be successful withion 10s`
    * `HTTP/HTTPS` - establush connection with endpoint `within 4 seconds` **and** respond with a status response code of 200-300 range within 2 seconds after connecting
    * `HTTP/HTTPS with string matching` - same rules as above and also research response body within 2 seconds and searches this for the string that you specify. String must appear entirely within the first 5120 bytes of the response body
    * `ENDPOINT` - Checks that assess the health of an endpoint you specify
    * `CloudWatch Alarm` - Use cloudwatch to check status of app
    * `Checks of Checks (calculated)` - gather lots of individual compenent / checks and route based on the status

## Failover Routing
* Allows you to add multple records with the same name eg www.domain.com. One will be the primary, one the secondary.
* Commonly used in active / standby
* Healthcheck occurs on primary record and DNS queries are returned based on primary
    * When fails the secondary DNS record will be used.

## Multivalue routing
* Create many records with the same name, which maps to a different endpoint
* Has associated health check
    * Up to 8 returned to client
    * If more than 8 exist, 8 at random are selected and returned
    * Any record which fails wont be returned when queried
* Aim to improve availability, useful in active/active setups
* Not substitute for LB

## Weighted Routing
* Used for simple form of load balancing or testing new versions of software (eg canary deployments)
* Can load say 80% to 1 record, 20% to another
* Setting record weight to 0 means it won't get returned
* Can combine this with health checks

## Latency based routing
* Used when trying to optimise performance and user experience
* Multiple records and attach a region to each record
* AWS has a database of latencies. Not real time. So when a query is done, it will look up responses to the region, if it has the lowest then it will route to that endpoint
* Can attach health checks to it - record returned is one with lowest latency AND healthy

## Geolocation routing
* Returns "relevant" records based on location of customers / resources
* Records tagged with `country`, `continent` or `default`
* IP check verifies location of the user
* Process:
    * Checks state -> country -> continent -> default -> returns most specific record or NO ANSWER if no matches
* Ideal if you want to restrict content eg only people from US or UK to be able to resolve the endpoint.

## Geoproximity routing
* Aims to provide records that are as close to customers as possible
* Aims to calculate based on distance and answers based on distance
* You define rules eg region or the latitude / longitude and a bias


