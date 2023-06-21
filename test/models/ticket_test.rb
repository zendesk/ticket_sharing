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

    expect(ticket.uuid)   .must_equal(attributes['uuid'])
    expect(ticket.subject).must_equal(attributes['subject'])
    expect(ticket.status) .must_equal(attributes['status'])
  end

  it 'parses json' do
    attributes = valid_ticket_attributes(
      'tags'        => ['foo', 'bar'],
      'original_id' => '12'
    )

    json = TicketSharing::JsonSupport.encode(attributes)
    ticket = described_class.parse(json)

    expect(ticket.uuid)       .must_equal(attributes['uuid'])
    expect(ticket.subject)    .must_equal(attributes['subject'])
    expect(ticket.status)     .must_equal(attributes['status'])
    expect(ticket.tags)       .must_equal(attributes['tags'])
    expect(ticket.original_id).must_equal(attributes['original_id'])
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
    expect(parsed_from_json['subject'])     .must_equal(ticket.subject)
    expect(parsed_from_json['status'])      .must_equal(ticket.status)
    expect(parsed_from_json['uuid'])        .must_equal(ticket.uuid)
    expect(parsed_from_json['requested_at']).must_equal(requested_at.strftime('%Y-%m-%d %H:%M:%S %z'))
    expect(parsed_from_json['tags'])        .must_equal(ticket.tags)
    expect(parsed_from_json['original_id']) .must_equal(ticket.original_id)
  end

  it 'serializes comments to json' do
    ticket = described_class.new(valid_ticket_attributes)

    ticket.comments << TicketSharing::Comment.new('uuid' => 'Comment1','body' => 'comment 1')
    ticket.comments.last.author = TicketSharing::Actor.new('uuid' => 'Actor1', 'name' => 'Actor One')

    ticket.comments << TicketSharing::Comment.new('uuid' => 'Comment2', 'body' => 'comment 2')
    ticket.comments.last.author = TicketSharing::Actor.new('uuid' => 'Actor2', 'name' => 'Actor Two')

    json = ticket.to_json
    expect(json).must_match(/Comment1.*Comment2/)
    expect(json).must_match(/Actor One.*Actor Two/)
    parsed_from_json = TicketSharing::JsonSupport.decode(json)

    expect(parsed_from_json['comments'].size).must_equal(2)
  end

  it 'includes requested in json serialization if present' do
    ticket = described_class.new(valid_ticket_attributes)
    ticket.requester = TicketSharing::Actor.new('name' => 'actor name')

    json = ticket.to_json
    hash = TicketSharing::JsonSupport.decode(json)

    expect(hash['requester']['name']).must_equal('actor name')
  end

  it 'deserializes the requester' do
    hash = {
      'requester' => {
        'name' => 'requester name'
      }
    }

    json = TicketSharing::JsonSupport.encode(hash)
    ticket = described_class.parse(json)

    expect(ticket.requester).must_be_kind_of(TicketSharing::Actor)
    expect(ticket.requester.name).must_equal('requester name')
  end

  it 'deserialize the current actor' do
    hash = {
      'current_actor' => {
        'name' => 'current actor'
      }
    }

    json = TicketSharing::JsonSupport.encode(hash)
    ticket = described_class.parse(json)

    expect(ticket.current_actor).must_be_kind_of(TicketSharing::Actor)
    expect(ticket.current_actor.name).must_equal('current actor')
  end

  it 'deserializes the comments' do
    hash = { 'comments' => [
              { 'body' => 'comment 0', 'author' => {'name' => 'Actor Zero'} },
              { 'body' => 'comment 1', 'author' => {'name' => 'Actor One'} }
            ]}

    json = TicketSharing::JsonSupport.encode(hash)
    ticket = described_class.parse(json)

    expect(ticket.comments[0]).must_be_kind_of(TicketSharing::Comment)
    expect(ticket.comments[0].body).must_equal('comment 0')
    expect(ticket.comments[0].author.name).must_equal('Actor Zero')

    expect(ticket.comments[1]).must_be_kind_of(TicketSharing::Comment)
    expect(ticket.comments[1].body).must_equal('comment 1')
    expect(ticket.comments[1].author.name).must_equal('Actor One')
  end

  it 'serializes the custom status' do
    ticket = described_class.new('custom_status' => "custom_status_str")
    json = ticket.to_json
    parsed_ticket = described_class.parse(json)
    expect(parsed_ticket.custom_status).must_equal "custom_status_str"
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

    expect(parsed_ticket.custom_fields['foo']).must_equal('bar')
    expect(parsed_ticket.custom_fields['one']).must_equal(2)
    expect(parsed_ticket.custom_fields['three']).must_equal([4, 5, 6])
    expect(parsed_ticket.custom_fields['hash']).must_equal('key' => 'value')
  end

  it 'sends to partner' do
    ticket = described_class.new(valid_ticket_attributes)
    ticket.agreement = TicketSharing::Agreement.new(
      'uuid' => '123', 'access_key' => 'abc'
    )

    expected_request = stub_request(:post, 'http://example.com/sharing/tickets/123abc').with do |request|
      request.headers['X-Ticket-Sharing-Token'] == ticket.agreement.authentication_token
    end

    expect(!!ticket.send_to('http://example.com/sharing')).must_equal true

    assert_request_requested expected_request
  end

  it 'updates partner' do
    expected_request = stub_request(:put, 'http://example.com/sharing/tickets/t1')
      .with(:headers => { 'X-Ticket-Sharing-Token' => 'a1:key' })

    ticket = described_class.new(valid_ticket_attributes('uuid' => 't1'))
    ticket.agreement = TicketSharing::Agreement.new(
      'uuid' => 'a1', 'access_key' => 'key'
    )

    expect(!!ticket.update_partner('http://example.com/sharing')).must_equal true

    assert_request_requested expected_request
  end

  it 'unshare' do
    expected_request = stub_request(:delete, 'http://example.com/sharing/tickets/t1')
      .with(headers: { 'X-Ticket-Sharing-Token' => 'a1:key' })

    ticket = described_class.new(valid_ticket_attributes('uuid' => 't1'))
    ticket.agreement = TicketSharing::Agreement.new(
      'uuid' => 'a1', 'access_key' => 'key'
    )

    expect(!!ticket.unshare('http://example.com/sharing')).must_equal true

    assert_request_requested expected_request
  end

  it 'sets requested_at from string' do
    ticket = described_class.new('requested_at' => '2011-01-02 13:01:01 -0500')
    expect(ticket.requested_at.to_time).must_equal(Time.parse('2011-01-02 13:01:01 -0500'))
  end

  it 'sets requested_at from time' do
    time = Time.now
    ticket = described_class.new('requested_at' => time)
    expect(ticket.requested_at.to_time).must_equal(time)
  end
end
