# Storage

## Blob storage
* Object storage (Binary Large Object)
* Blob data stored inside container which is stored inside a storage account
* Each blob item has a unique identity
* Versatile to suit a number of scenarios eg store images, streaming, log files, data store etc
* 3 Types of blobs
    * `Block` - store text / binary up to 4.7TB. Made up of individual blocks of data
    * `Append` - Block blobs optimised for append operations. Works well for logging where data is constantly appended
    * `Page` - store files upto 8TB. Eg for like a virtual drive
* 3 main pricing tiers
    * `Hot` - contstantly accessed files. Low access times but higher access costs
    * `Cool`  lower storage costs but higher access times. Data remains here for at least 30 days
    * `Archive` - lowest cost and highest access times

## Disk storage
* `Managed disk` that you can attach to a server
* 4 main types increasing in price:
    * `HDD` - old school hartd driove. Low cost suitable for back up or testing
    * `SSD` - Standard for production. Lower latency over HDD
    * `Premium SSD` - Best for DB or hard read / write critical workloads
    * `Ultra disk` - For most demanding, data intensive workloads. Disks up to 64TB

## File storage
* Share access across multiple machines
* Fully managed
* Resilient

## Archive
* Durable, encrypted, secure, low cost and stable.
* Perfectly suited for data that is accessed infrenquently
* A blob storage tier

## Storage redundancy
* Multiple replicated copies of your data is created. 
* Azure storage always has: 
    * Minimum 3 copies of data
    * Automatic
    * Invisible to end user
* Different scopes - Single zone, Multiple zone, multiple regions
* Higher availability = higher cost
* `Locally redundant storage` aka LRS
    * Copies in a single data centre / zone
    * Lowest cost
    * Protects again single disk failure
    * If AZ is unavailable, data is unavaialble.
* `Zone Redundant Storage`
    * Single region
    * Copies of data will be spread across each AZ in the region
    * Protects from a zone outage
* `Geo redundant storage` aka GRS
    * Copies of data are in primary LRS AND available in a secondary LRS in another region
    * Does not give zone redundancy
    * Can configure read access from secondary region
* `Geo Zone Redundant Storage` GZRS
    * Maximum redundancy and highest cost
    * Copies data across primary region AZ AND seconday region AZ
    * Protects against zone and region failure
    * Can configure read access from secondary region

## Moving data
The following are used for transfering "small amounts of data"

* `AzCopy` - cmdline utility. 
    * Useful for transfering blobs and azure storage
    * Useful for scripting data transfers
* `Storage Explorer` - GUI
    * Downloaded application
    * User friendly, similar to Windows explorer
    * All storage account formats can be moved
* `AzureFileSync` - syncronize azure files witth on premsdis file servers
    * Local file server performance with cloud availability
    * Use cases including backing up local file servers and / or synchronising between multiple on premisis locations
    * Remote user accessing azure files
    

## Additional migration options
Used for larger data migration options
* `Azure Data Box`
    * Used for transfering A LOT of data and/or limited data bandwidth
    * An offline data transfer box to transfer to/from azure
    * Copy to phyiscal storage device
    * Its encrypted / rugged
    * Ship to azure and Azure transfer it to a pre-created storage account
* `Azure Migrate service`
    * Migrate non azure resources into Azure - eg servers, DBs or applications
    * Does discovery, transformation and migration

## Premium performance options
3 Premium performance options
* All operate with SSDs, different considerations from managed disk types
* `Premium block blobs`
    * Supports blob storage
    * Ideal for low-latency blob storage workloads eg AI apps, IoT analytics
    * Redundary is LRS/ZRS only
* `Premium Page blobs`
    * supports page blocvk storage types
    * Only supports LRS (single zone) redundancy
* `Premium file shares`
    * Supports Azure files
    * Ideal for high performance enterprise file server applications
    * Supports SMB and NFS
    * Redundancy is LRS/ZRS only