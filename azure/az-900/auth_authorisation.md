# Authentication and Authorization

## Azure Active Directory
* Main tool to manage users and permissions
* Referred to as AAD (Azure Active Directory)
* Mandaory service to have
* Must have first user in AAD
* Tenant
    * A tenant represents an organisation
    * Dedidicated AAD instance
    * Each tenant is distrinct and completely separate from other AAD tenants
    * One user - one tenant relationship. Each user can only belong to one tenant but can be "guests" in other tenants
* Subscription
    * Billing entity. All resources within subscription are billed together
    * Cost separation - multiple subscriptions within a single tenant
    * If unpaid, resources in subscription will stop