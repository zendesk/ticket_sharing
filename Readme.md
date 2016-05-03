# Ticket Sharing [![Build Status](https://secure.travis-ci.org/zendesk/ticket_sharing.png)](http://travis-ci.org/zendesk/ticket_sharing)

A ruby implementation of the [Networked Help Desk] [1] API

## Installation

    gem install ticket_sharing

## Usage

### Creating an agreement

    agreement = TicketSharing::Agreement.new('uuid' => '5ad614f4')
    agreement.send_to('http://example.com/sharing')

### Sending a ticket

    ticket = TicketSharing::Ticket.new(
      'uuid' => 'fc8daf77',
      'subject' => 'the subject',
      'requested_at' => '2011-01-17 01:01:01',
      'status' => 'new'
    )
    ticket.send_to('http://example.com/sharing')

### Updating a ticket

    ticket = TicketSharing::Ticket.new('status' => 'new')
    ticket.update_partner('http://example.com/sharing')

## Contributing

* [Submit an issue] [2]
* Fork the project and submit a pull request

[1]: http://networkedhelpdesk.org/api/ "Networked Help Desk"
[2]: https://github.com/zendesk/ticket_sharing/issues "Issues"

## Author
[Josh Lubaway](https://github.com/jish)<br/>

## Copyright and license

Copyright 2013 Zendesk

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific
language governing permissions and limitations under the License.
