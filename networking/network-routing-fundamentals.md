## Address Resolution Protocol (ARP):

  Used to map physical MAC address to assigned IP address

  `ARP request`:
    Message sent by host to obtain physical address of the host it wishes to communicate with

  `ARP Response`:
    Sent in reply to ARP request which contains the physical address

  `Proxy ARP`:
    When one device responds to ARP requests on behalf of another device

  `ARP Cache`:
    Like a DNS cache except for physical addresses. Table is consulted in order to direct the network
    communication. If an entry doesn't exist in the cache the ARP request is sent to get address

## Network Address Translation (NAT):

  Used to map a public IP routable IP address to a private IP address and vice versa

  `Static NAT:`
    NAT device is assigned a pool of public IP addresses

    Private IP mapped to the public addresses

    Used in situations where servers always need to go to the same public address
    e.g. Mail server, website requiring access which is access controlled by firewall in another company

  `Dynamic NAT`:
    NAT device is assigned a pool of public IP addresses

    Public IP address are used when needed then return to pool when no longer needed

    On demand use of public IPs - e.g. if you are web scraping and want to reduce being blocked / rate limited

  `Port Address Translation`:
    A single IP is assigned to network

    All devices share the single IP address

    NAT device records private IP + port - aka source port

    Most common type of NAT

    Helps conserve number of available IPs

  `Source NAT (SNAT)`:
    Preserves destination address and modifies source address

    Allows hosts on private network to initiate connection to hosts outside the private network

  `Destination NAT (DNAT) aka port forwarding`:
    Preserves source address but modifies destination

    Allows multiple hosts outside the private network to connect to a host inside the private network

    Advantages:
      Helps avoid IP addresses running outside
    Disadvantage:
      Takes resource to perform NAT
      Prevents ability to do full end to end trace

## Network types:

  `Personal Area Network (PAN)`:
    Computers connected via a single device e.g. home router

  `Local Area Network (LAN)`:
    One of the most common network types.
    Multiple computers and devices connected at a single site e.g. a London office

  `Metropolitan Area Network (MAN)`:
    Spread across a small area or region, e.g. college campus.
    Basically multiple LANs connected together in a somewhat close proximity

  `Wide Area Network`:
    Spans over large geographical locations e.g. the internet or a UK & US connection
    Made possible by NAT

## OSI Model:

  `Layer 7`:
    Application layer - Deals directly with software application.
    Implements several different protocols so that communication can happen between different computer programs

  `Layer 6`:
    Presentation layer - not widely used but ensures the transferred data is in the proper format

  `Layer 5`:
    Session layer - manages dialogue / sessions between computers

  `Layer 4`:
    Transport layer - facilitate reliable end to end data transfer.
    Segmented before transferred
    Main protocols - TCP / UDP

  `Layer 3`:
    Network Layer - standards for network to go through multiple devices eg "packets"
    Network layers job to ensure packets reach their destination

  `Layer 2`:
    Data link - node to node transfer through the link
    Usually done with Ethernet software that runs on network devices like switches

  `Layer 1`:
    Physical layer - dealing with actual hardware


## TCP / IP Models:

  `Layer 4`: Application

      Equals application, presentation and session layer

  `Layer 3`: Transport

      Mirrors transport layer. Provides reliable end to end communication

  `Layer 2`: Internet

      Matches network later of OSI model

  `Layer 1`: Network Access/link

      Combination of physical and data layer

## Network Transmissions:

  `Unicast`:

    One to one transmission model - single source / destination

    Most common type of communication

    Supports use of TCP

    servers can still have multiple clients

  `Multicast`:

    One to many or many to many transmission model

    Requires membership of a group to receive data

    Data replicated across network devices like routers and switches

    Primarily done with UDP

  `Broadcast`:

    one to all transmission Model - send from 1 host to all hosts connected to the same Network

    For example used with ARP

    switches designed to forward broadcast messages

    routers designed to drop broadcast messages

    Removed in IPv6

## Routing types:

  `Static routing`:

    When you configure manually and it doesn't change

    Generally used in small networks

    Default route will be set when no other routes are available for intended destination

  `Dynamic routing`:

    Routing protocols configured before hand - allows admins to be more hands free

    Shares connection information with connected routers

    Detects route changes

    Discovers remote networks

## Route Tables:

  Reserved routing Tables

  Local routing Tables

  Main routing Table

  Default routing Table

  Routing Cache -> consulted before the routing tables

## Managing and routing tools on linux:

  `iproute2` - collection of utilities for managing/monitoring networks

  `ip addr` - ip address management - replaces `ifconfig` command

  `ip link` - network device configuration

  `ip neigh` - ARP/neighbour tables management - replaces `arp` command

  `ip rule` - routing policy database

  `ip route` - routing table management - replaces `route` command

  `ping` - ICMP echo to a network host

  `traceroute` - tracks the routes the packets take to a destination

## IP forwarding on a linux host:

  Can google commands later but process is:

  1 - configure host A with a static route

  2 - configure host b to enable ip forwarding
