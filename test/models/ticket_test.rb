require 'test_helper'
require 'ticket_sharing/ticket'

describe TicketSharing::Ticket do
  let(:described_class) { TicketSharing::Ticket }

  def valid_ticket_attributes(options={})
    {
      'uuid'         => '123abc',
      'subject'      => 'the subject',
      'requested_at' => '2011-01-17 01:01:01',
      'status'       => 'new'
    }.merge(options)
  end

  it 'initializes' do
    attributes = valid_ticket_attributes

    ticket = described_class.new(attributes)

    assert_equal attributes['uuid'], ticket.uuid
    assert_equal attributes['subject'], ticket.subject
    assert_equal attributes['status'], ticket.status
  end

  it 'parses json' do
    attributes = valid_ticket_attributes(
      'tags'        => ['foo', 'bar'],
      'original_id' => '12'
    )

    json = TicketSharing::JsonSupport.encode(attributes)
    ticket = described_class.parse(json)

    assert_equal attributes['uuid'], ticket.uuid
    assert_equal attributes['subject'], ticket.subject
    assert_equal attributes['status'], ticket.status
    assert_equal attributes['tags'], ticket.tags
    assert_equal attributes['original_id'], ticket.original_id
  end

  it 'serializes to json' do
    requested_at = Time.now
    ticket = described_class.new(
      valid_ticket_attributes(
        'requested_at' => requested_at,
        'tags'         => ['foo', 'bar'],
        'original_id'  => '12'
      )
    )
    json = ticket.to_json

    parsed_from_json = TicketSharing::JsonSupport.decode(json)
    assert_equal ticket.subject, parsed_from_json['subject']
    assert_equal ticket.status, parsed_from_json['status']
    assert_equal ticket.uuid, parsed_from_json['uuid']
    assert_equal requested_at.strftime('%Y-%m-%d %H:%M:%S %z'), parsed_from_json['requested_at']
    assert_equal ticket.tags, parsed_from_json['tags']
    assert_equal ticket.original_id, parsed_from_json['original_id']
  end

  it 'serializes comments to json' do
    ticket = described_class.new(valid_ticket_attributes)

    ticket.comments << TicketSharing::Comment.new('uuid' => 'Comment1','body' => 'comment 1')
    ticket.comments.last.author = TicketSharing::Actor.new('uuid' => 'Actor1', 'name' => 'Actor One')

    ticket.comments << TicketSharing::Comment.new('uuid' => 'Comment2', 'body' => 'comment 2')
    ticket.comments.last.author = TicketSharing::Actor.new('uuid' => 'Actor2', 'name' => 'Actor Two')

    json = ticket.to_json
    assert_match(/Comment1.*Comment2/, json)
    assert_match(/Actor One.*Actor Two/, json)
    parsed_from_json = TicketSharing::JsonSupport.decode(json)

    assert_equal 2, parsed_from_json['comments'].size
  end

  it 'includes requested in json serialization if present' do
    ticket = described_class.new(valid_ticket_attributes)
    ticket.requester = TicketSharing::Actor.new('name' => 'actor name')

    json = ticket.to_json
    hash = TicketSharing::JsonSupport.decode(json)

    assert_equal 'actor name', hash['requester']['name']
  end

  it 'deserializes the requester' do
    hash = {
      'requester' => {
        'name' => 'requester name'
      }
    }

    json = TicketSharing::JsonSupport.encode(hash)
    ticket = described_class.parse(json)

    assert_kind_of TicketSharing::Actor, ticket.requester
    assert_equal 'requester name', ticket.requester.name
  end

  it 'deserialize the current actor' do
    hash = {
      'current_actor' => {
        'name' => 'current actor'
      }
    }

    json = TicketSharing::JsonSupport.encode(hash)
    ticket = described_class.parse(json)

    assert_kind_of TicketSharing::Actor, ticket.current_actor
    assert_equal 'current actor', ticket.current_actor.name
  end

  it 'deserializes the comments' do
    hash = { 'comments' => [
              { 'body' => 'comment 0', 'author' => {'name' => 'Actor Zero'} },
              { 'body' => 'comment 1', 'author' => {'name' => 'Actor One'} }
            ]}

    json = TicketSharing::JsonSupport.encode(hash)
    ticket = described_class.parse(json)

    assert_kind_of TicketSharing::Comment, ticket.comments[0]
    assert_equal 'comment 0', ticket.comments[0].body
    assert_equal 'Actor Zero', ticket.comments[0].author.name

    assert_kind_of TicketSharing::Comment, ticket.comments[1]
    assert_equal 'comment 1', ticket.comments[1].body
    assert_equal 'Actor One', ticket.comments[1].author.name
  end

  it 'serializes the custom status' do
    ticket = described_class.new('custom_status' => "custom_status_str")
    json = ticket.to_json
    parsed_ticket = described_class.parse(json)
    assert_equal "custom_status_str", parsed_ticket.custom_status
  end

  it 'serializes the custom fields' do
    custom_fields = {
      'foo' => 'bar',
      'one' => 2,
      'three' => [4, 5, 6],
      'hash' => { 'key' => 'value' }
    }

    ticket = described_class.new('custom_fields' => custom_fields)
    json = ticket.to_json
    parsed_ticket = described_class.parse(json)

    assert_equal 'bar', parsed_ticket.custom_fields['foo']
    assert_equal 2, parsed_ticket.custom_fields['one']
    assert_equal [4, 5, 6], parsed_ticket.custom_fields['three']
    assert_equal({ 'key' => 'value' }, parsed_ticket.custom_fields['hash'])
  end

  it 'sends to partner' do
    ticket = described_class.new(valid_ticket_attributes)
    ticket.agreement = TicketSharing::Agreement.new(
      'uuid' => '123', 'access_key' => 'abc'
    )

    expected_request = stub_request(:post, 'http://example.com/sharing/tickets/123abc').with do |request|
      request.headers['X-Ticket-Sharing-Token'] == ticket.agreement.authentication_token
    end

    assert_equal true, !!ticket.send_to('http://example.com/sharing')

    assert_request_requested expected_request
  end

  it 'updates partner' do
    expected_request = stub_request(:put, 'http://example.com/sharing/tickets/t1')
      .with(:headers => { 'X-Ticket-Sharing-Token' => 'a1:key' })

    ticket = described_class.new(valid_ticket_attributes('uuid' => 't1'))
    ticket.agreement = TicketSharing::Agreement.new(
      'uuid' => 'a1', 'access_key' => 'key'
    )

    assert_equal true, !!ticket.update_partner('http://example.com/sharing')

    assert_request_requested expected_request
  end

  it 'unshare' do
    expected_request = stub_request(:delete, 'http://example.com/sharing/tickets/t1')
      .with(headers: { 'X-Ticket-Sharing-Token' => 'a1:key' })

    ticket = described_class.new(valid_ticket_attributes('uuid' => 't1'))
    ticket.agreement = TicketSharing::Agreement.new(
      'uuid' => 'a1', 'access_key' => 'key'
    )

    assert_equal true, !!ticket.unshare('http://example.com/sharing')

    assert_request_requested expected_request
  end

  it 'sets requested_at from string' do
    ticket = described_class.new('requested_at' => '2011-01-02 13:01:01 -0500')
    assert_equal Time.parse('2011-01-02 13:01:01 -0500'), ticket.requested_at.to_time
  end

  it 'sets requested_at from time' do
    time = Time.now
    ticket = described_class.new('requested_at' => time)
    assert_equal time, ticket.requested_at.to_time
  end
end
