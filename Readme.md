# Ticket Sharing [![Build Status](https://github.com/zendesk/ticket_sharing/actions/workflows/ruby.yml/badge.svg)](https://github.com/zendesk/ticket_sharing/actions/workflows/ruby.yml)

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

### Releasing a new version
A new version is published to RubyGems.org every time a change to `version.rb` is pushed to the `main` branch.
In short, follow these steps:
1. Update `version.rb`,
2. run `bundle lock` to update `Gemfile.lock`,
3. merge this change into `main`, and
4. look at [the action](https://github.com/zendesk/ticket_sharing/actions/workflows/publish.yml) for output.

To create a pre-release from a non-main branch:
1. change the version in `version.rb` to something like `1.2.0.pre.1` or `2.0.0.beta.2`,
2. push this change to your branch,
3. go to [Actions → “Publish to RubyGems.org” on GitHub](https://github.com/zendesk/ticket_sharing/actions/workflows/publish.yml),
4. click the “Run workflow” button,
5. pick your branch from a dropdown.

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

[1]: http://networkedhelpdesk.org/api/ "Networked Help Desk"
[2]: https://github.com/zendesk/ticket_sharing/issues "Issues"
