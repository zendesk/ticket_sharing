require 'test_helper'
require 'ticket_sharing/agreement'

describe TicketSharing::Agreement do
  let(:described_class) { TicketSharing::Agreement }

  it 'initializes with attributes' do
    attributes = {
      'receiver_url'           => 'http://example.com/sharing',
      'sender_url'             => 'http://example.net/partners',
      'status'                 => 'pending',
      'sync_tags'              => true,
      'sync_custom_fields'     => true,
      'allows_public_comments' => true
    }

    agreement = described_class.new(attributes)

    assert_equal attributes['receiver_url'], agreement.receiver_url
    assert_equal attributes['sender_url'], agreement.sender_url
    assert_equal attributes['status'], agreement.status
    assert_equal attributes['sync_tags'], agreement.sync_tags
    assert_equal attributes['sync_custom_fields'], agreement.sync_custom_fields
    assert_equal attributes['allows_public_comments'], agreement.allows_public_comments
  end

  it 'generates a authentication token' do
    attributes = {
      'uuid'       => '<uuid>',
      'access_key' => '<access_key>'
    }
    agreement = described_class.new(attributes)
    assert_equal "<uuid>:<access_key>", agreement.authentication_token
  end

  it 'marshals from json' do
    json = TicketSharing::JsonSupport.encode(
      'name'         => 'Organization Foo',
      'uuid'         => 'the_uuid',
      'access_key'   => 'the_access_key',
      'receiver_url' => 'http://example.com/sharing',
      'sender_url'   => 'http://example.net/partners',
      'status'       => 'pending',
      'allows_public_comments' => true
    )

    agreement = described_class.parse(json)

    assert_equal 'Organization Foo', agreement.name
    assert_equal 'the_uuid', agreement.uuid
    assert_equal 'the_access_key', agreement.access_key
    assert_equal 'http://example.com/sharing', agreement.receiver_url
    assert_equal 'http://example.net/partners', agreement.sender_url
    assert_equal 'pending', agreement.status
    assert_equal true, agreement.allows_public_comments
  end

  def test_json_serialization
    agreement = described_class.new
    agreement.status = 'pending'

    json = agreement.to_json
    assert_match(/status/, json)
  end

  it 'serializes and deserializes' do
    attributes = {
      'name'         => 'Organization Foo',
      'receiver_url' => 'http://example.com/sharing',
      'sender_url'   => 'http://example.net/partners',
      'status'       => 'pending'
    }
    agreement = described_class.new(attributes)

    json = agreement.to_json
    agreement2 = described_class.parse(json)

    assert_equal agreement.name, agreement2.name
    assert_equal agreement.receiver_url, agreement2.receiver_url
    assert_equal agreement.sender_url, agreement2.sender_url
    assert_equal agreement.status, agreement2.status
  end

  it 'sends to partner' do
    attributes = {
      'receiver_url' => 'http://example.com/sharing',
      'uuid'         => '5ad614f4'
    }

    agreement = described_class.new(attributes)
    stub_request(:post, 'http://example.com/sharing/agreements/5ad614f4')

    assert_equal true, !!agreement.send_to(attributes['receiver_url'])
  end

  it 'raises when unable to send to partner' do
    attributes = {
      'receiver_url' => 'http://example.com/sharing',
      'uuid'         => '5ad614f4'
    }

    agreement = described_class.new(attributes)
    stub_request(:post, 'http://example.com/sharing/agreements/5ad614f4')
      .to_return(status: 400)

    assert_raises TicketSharing::Error do agreement.send_to(attributes['receiver_url']) end
  end

  it 'updates partner' do
    stub_request(:put, 'http://example.com/sharing/agreements/5ad614f4')
      .with(body: /5ad614f4/, headers: { 'X-Ticket-Sharing-Token' => '5ad614f4:APIKEY123' })

    attributes = {
      'receiver_url' => 'http://example.com/sharing',
      'uuid'         => '5ad614f4',
      'access_key'   => 'APIKEY123'
    }

    agreement = described_class.new(attributes)
    assert_equal true, !!agreement.update_partner(attributes['receiver_url'])
  end

  it 'deserializes current actor' do
    json = TicketSharing::JsonSupport.encode(
      'current_actor' => {
        'uuid' => '1234',
        'name' => 'Remote Dude'
      }
    )

    agreement = described_class.parse(json)
    refute_nil agreement.current_actor
    assert_equal '1234', agreement.current_actor.uuid
    assert_equal 'Remote Dude', agreement.current_actor.name
  end

end
