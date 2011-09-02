# Ticket Sharing

A ruby implementation of the [Networked Help Desk] [1] API

## Installation

    gem install ticket_sharing

## Usage

### Creating an agreement

    agreement = TicketSharing::Agreement.new({'uuid' => '5ad614f4'})
    agreement.send_to('http://example.com/sharing')

### Sending a ticket

    ticket = TicketSharing::Ticket.new({
      'uuid' => 'fc8daf77',
      'subject' => 'the subject',
      'requested_at' => '2011-01-17 01:01:01',
      'status' => 'new'
    })
    ticket.send_to('http://example.com/sharing')

### Updating a ticket

    ticket = TicketSharing::Ticket.new({'status' => 'new'})
    ticket.update_partner('http://example.com/sharing')

## Contributing

* [Submit an issue] [2]
* Fork the project and submit a pull request

[1]: http://networkedhelpdesk.org/api/ "Networked Help Desk"
[2]: https://github.com/zendesk/ticket_sharing/issues "Issues"
