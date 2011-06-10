Ticket Sharing
==============

Overview
--------

Typically, a company’s help desk is a silo. Tickets come in, they're assigned, prioritized,
answered and an email response is sent back to the customer. The same thing happens across
companies’ partners, but often with different software tools and solutions being used at the
help desk. When a customer needs help from a company and its partners at the same time, things
often get bogged down because of their use of different customer service software.

In today's world of high-speed communication that's not good enough. Ecosystems of partners,
sister companies and out-sourcing is very common across multiple industries.

The NetworkedHelpDesk.org ticket sharing API allows you to change that. The vision is that your
customers can share any ticket in your help desk with any other help desk, regardless of the software
being used. By sharing tickets, you're opening up collaboration with other help desks, companies and
software; breaking down the walls of the help desk silo.


Terminology
-----------

### General

* **Ticket** - A typical help desk terminology for a user submitted question, problem, etc. This is synonymous with case, story, issue, etc.
* **Ticket sharing** - This is the notion of actually taking a ticket (or case, story, issue, etc) and sending it elsewhere, be it another help desk, bug tracker or any other software.
* **Sender** - Is someone sending tickets to another location.
* **Receiver** - Is someone receiving tickets from a Sender. Note that either the Sender or Receiver may actually be on the same software provider, or completely different providers.
* **Agreement** - An agreement is a set of permissions (explained below) created by a Sender in order to control what it is the Receiver can actually do with tickets that the Sender shares.
* **Agreement Invite** - Simply the action of sending an invitation to a potential Receiver which outlines the permissions of the agreement for them to either accept or decline.
* **Full delegation** - When an agreement exists between a Sender and a Receiver, there are a set of permissions which restricnder. Note that either the Sender or Receiver may actually be on the same software provider, or completely different providers.
* **Agreement** - An agreement is a set of permissions (explained below) created by a Sender in order to control what it is the Receiver can actually do with tickets that the Sender shares.
* **Agreement** Invite - Simply the action of sending an invitation to a potential Receiver which outlines the pl,ined below) created by a Sender in order to control what it is the Receiver can actually do with tickets that the Sender shares.
* **Agreement Invite** - Simply the action of sending an i c the Receiver can actually do with tickets that the Sender st,e agreement for them to either accept or decline.
* **Full delegation** - When an agreement exists between a Sender and a Receiver, there are a se

### Technical

* **UUID** - A Universally Unique IDentifier.
* **Access Key** - A secret key which grants a help desk access to interact with tickets in another help desk. Do not share this key with anyone.
* **X-Ticket-Sharing-Token** - A combination of `UUID` and `Access Key` combined to form a single string, i.e. `UUID:Access Key`.


Generating UUIDs
----------------
[UUID: Universally Unique IDentifier](http://en.wikipedia.org/wiki/Universally_unique_identifier) (also commonly called GUID: Globally Unique IDentifier)

Every Ticket Sharing resource requires its own identifier that is unique across all systems
that share tickets. The primary resources in Ticket Sharing are agreements, tickets, authors
and comments. If your system is the origin of one of these resources, then your system is
required to generate the Unique Identifier.

A UUID is created by joining the following:

* a help desk's sharing uri (e.g. `mycompany.net/sharing`)
* a resource type (e.g. `tickets`)
* a resource's unique identifier (e.g. `1`)

(e.g.: `<helpdesk_uuid>/<resource_type>/<resource_id>`)

The first part, `mycompany.net/sharing`, uniquely identifies a particular organization.
More importantly, it is unique for a single system that is sharing tickets.

It is important that a resource's UUID is unique across all Ticket Sharing systems.
This value should describe one and only one resource. This will ensure that it can be
used across all systems as a unique identifier.

This value should be hashed with SHA-1, to make it suitable for use in URLS.
(e.g `mycompany.net/sharing/tickets/1` becomes `ed46838bfb41461e4f3b16ba471162c8e2764260`)


Agreements
----------
Agreements can be likened to a Facebook friend request. In Facebook, you can invite someone
to be your friend, which allows them to do certain things such as look at your photos or status updates.

In Zendesk it's very similar. You send an agreement invite to another software provider with
a set of permissions outlined, either Full Delegation or Partial Delegation.

If the Receiver accepts the agreement, then sharing can begin straight away under the permissions
set out in the agreement. If the Receiver declines the invitation, then sharing may not occur.

### Sending an agreement invitation (or creating an agreement)

To create an agreement, the sender must fist generate a `uuid` and an `access_key`.
Then the sender must post an agreement request to the receiver's helpdesk.

    POST <partner_url>/agreements/<agreement_uuid>
    
    {
      "uuid": "23538de2af57572219a037c98aa4623a6767a498",
      "name": "Sender Company Name",
      "receiver_url": "http://mypartner.com/sharing",
      "sender_url": "http://mycompany.net/sharing",
      "access_key": "08a479474fc0c3fabfa2b7906f0ce5e55ad2d78f",
      "status": "pending"
    }

_NOTE: status should always be pending on creation._

### Agreement status

There are 4 statuses of which apply to an agreement:

**Pending** - An agreement in pending means the invitation has been sent to the "receiver" but not yet accepted or declined. This is the default state on creation.
**Accepted** - The agreement is active, the invite was accepted.
**Declined** - The agreement was never made active, the invite was declined.
**Inactive** - The agreement has been deactivated by either "sender" or "receiver".

### Authentication

Once an agreement has been established between two help desks, authentication credentials
must be provided for all other types of requests. Authenticating will be done by setting
the `X-Ticket-Sharing-Token` header.

The value of this header should be the uuid of the agreement, and the access_key joined
by a colon `<agreement_uuid>:<access_key>`.

### Updating an agreement
To update an agreement the receiver must set the `X-Ticket-Sharing-Token` header and provide
the sender with the updated agreement payload (e.g., the status is now "accepted").

    PUT <partner_url>/agreements/<agreement_uuid>
    X-Ticket-Sharing-Token: <agreement_uuid>:<access_key>
    
    {
      "uuid": "23538de2af57572219a037c98aa4623a6767a498",
      "name": "Receiver Company Name",
      "receiver_url": "http://mypartner.com/sharing",
      "sender_url": "http://mycompany.net/sharing",
      "status": "accepted"
    }

### Sharing a ticket

To share a ticket, the sender must first generate a uuid for that ticket. For example:

    uuid = 'mycompany.net/sharing/tickets/1' => ed46838bfb41461e4f3b16ba471162c8e2764260

That uuid should be included in the url as well as the ticket payload. A request that creates a ticket would take the following form...

    POST <partner_url>/tickets/<uuid>
    X-Ticket-Sharing-Token: <agreement_uuid>:<access_key>
    
    {
      // entire ticket payload
    }

Sharing & Syncing tickets
-------------------------

The sharing of tickets is done by an agent on an individual ticket level, but could
also be done by automated workflow rules. In the ticket sharing API, it's done on
an individual ticket basis.

By pushing a ticket to be shared, you send the ticket from the receiver to the sender,
which will include all the details about the ticket.

### Pushing a ticket to be shared.
An example of this request:

    POST http://mypartner.com/sharing/tickets/8c0c8a19a3c598be24047eee940c7ce4c259d1bb
    X-Ticket-Sharing-Token: 23538de2af57572219a037c98aa4623a6767a498:08a479474fc0c3fabfa2b7906f0ce5e55ad2d78f

    {
      "uuid": "8c0c8a19a3c598be24047eee940c7ce4c259d1bb",
      "subject": "Trial expiry time mismatch",
      "requested_at": "2010-11-24 14:13:54 -0800",
      "status": "open",
      "requester": {
        "uuid": "9b80c1331d9d746c493a8b8e6d3014347469615e",
        "name": "Joe User"
      },
      "comments": [
      {
        "uuid": "59e8c53b5c39716e510127e004cc01fc7aaaecd2",
        "author": {
          "uuid": "9b80c1331d9d746c493a8b8e6d3014347469615e",
          "name": "Joe User"
        },
        "body": "Hello Company Support, I would like some help."
          "authored_at": "2010-11-24 14:13:54 -0800"
      },
      {
        "uuid": "4a7542fc9267d94a532ab7221726bd81f087fc87",
        "author": {
          "uuid": "127fabf85992fd86091e5e449aa531d6c2eb8116",
          "name": "Agent Smith"
        },
        "body": "Hello Joe, How can I help you?",
        "authored_at": "2010-11-24 14:25:23 -0800"
      }]
    }

### Updating a ticket

The request to update a ticket is very similar in form to the request for sharing a ticket.
The actual endpoint is the same. However, the request should be an HTTP PUT, instead of an HTTP POST.

The update endpoint will accept changes and ignore previously set values. For example if a
ticket has a status of "pending" and no value for status is provided, the ticket's status
will remain "pending". If status is provided, and the value is "pending", the ticket's status
will again, remain unchanged. However, if status is provided and it contains an updated value (e.g "open"),
then the ticket's status will be updated (e.g. to "open").

For example if the status is already set, you are not required to send it. If it is omitted,
it will remain unchanged. If a status is provided, and it is different than the current status,
the status of the ticket will be updated.

The same goes for comments. If comments are already present on a ticket, they need not be passed
across again. If they are passed across, the uuid is usedicket's status will again, remain unchanged.
However, if status is provided and it contains an updated value (e.g "open"), then the ticket's
status will be updated (e.g. to "open").

For example if the status is already set, you are not required to send it. If it is omitted,
it will remain unchanged. If a status is provided, and it is different than the current status,
the status of the ticket will be updated.

The same goes for comments. If comments omments are already present on

An example update would look like:

    PUT http://mypartner.com/sharing/tickets/8c0c8a19a3c598be24047eee940c7ce4c259d1bb
    X-Ticket-Sharing-Token: 23538de2af57572219a037c98aa4623a6767a498:08a479474fc0c3fabfa2b7906f0ce5e55ad2d78f
    
    {
      "uuid": "8c0c8a19a3c598be24047eee940c7ce4c259d1bb",
      "status": "pending",
      "current_actor": {
        "uuid": "7e806b7d962be5afdafcd95d9d53498af2ea5b1f",
        "name": "Agent Name"
      },
      "comments": [
      {
        "uuid": "184313b9e6347dcade7245123b330af2a5b82a86",
        "author": {
          "uuid": "7e806b7d962be5afdafcd95d9d53498af2ea5b1f",
          "name": "Agent Name"
        },
        "body": "Hi, I am the agent that will help you.",
        "authored_at": "2010-11-24 15:14:24 -0800"
      }]
    }

Attachments
-----------
Attachments can optionally be included on each comment. An attachment consists
of a url* _(required)_ and a filename* _(required)_.

    "comments": [
    {
      "body": "Hi, this is a comment with some attachments.",
        // The rest of a typical comment payload ...
        "attachments": [
        {
          "url": "http://example.com/foo.jpg",
          "filename": "foo.jpg"
        },
        {
          "url": "http://example.net/attachments/bar.jpg",
          "filename": "bar.jpg"
        }
      ]
    }]
