require 'spec_helper'
require 'ticket_sharing/agreement'

describe TicketSharing::Agreement do

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

    expect(agreement.receiver_url)          .to eq(attributes['receiver_url'])
    expect(agreement.sender_url)            .to eq(attributes['sender_url'])
    expect(agreement.status)                .to eq(attributes['status'])
    expect(agreement.sync_tags)             .to eq(attributes['sync_tags'])
    expect(agreement.sync_custom_fields)    .to eq(attributes['sync_custom_fields'])
    expect(agreement.allows_public_comments).to eq(attributes['allows_public_comments'])
  end

  it 'generates a authentication token' do
    attributes = {
      'uuid'       => '<uuid>',
      'access_key' => '<access_key>'
    }
    agreement = described_class.new(attributes)
    expect(agreement.authentication_token).to eq("<uuid>:<access_key>")
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

    expect(agreement.name)                  .to eq('Organization Foo')
    expect(agreement.uuid)                  .to eq('the_uuid')
    expect(agreement.access_key)            .to eq('the_access_key')
    expect(agreement.receiver_url)          .to eq('http://example.com/sharing')
    expect(agreement.sender_url)            .to eq('http://example.net/partners')
    expect(agreement.status)                .to eq('pending')
    expect(agreement.allows_public_comments).to eq(true)
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

    expect(agreement2.name)        .to eq(agreement.name)
    expect(agreement2.receiver_url).to eq(agreement.receiver_url)
    expect(agreement2.sender_url)  .to eq(agreement.sender_url)
    expect(agreement2.status)      .to eq(agreement.status)
  end

  it 'sends to partner' do
    attributes = {
      'receiver_url' => 'http://example.com/sharing',
      'uuid'         => '5ad614f4'
    }

    agreement = described_class.new(attributes)
    stub_request(:post, 'http://example.com/sharing/agreements/5ad614f4')

    expect(agreement.send_to(attributes['receiver_url'])).to be_truthy
  end

  it 'raises when unable to send to partner' do
    attributes = {
      'receiver_url' => 'http://example.com/sharing',
      'uuid'         => '5ad614f4'
    }

    agreement = described_class.new(attributes)
    stub_request(:post, 'http://example.com/sharing/agreements/5ad614f4')
      .to_return(status: 400)

    expect(agreement.send_to(attributes['receiver_url'])).to be(400)
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
    expect(agreement.update_partner(attributes['receiver_url'])).to be_truthy
  end

  it 'deserializes current actor' do
    json = TicketSharing::JsonSupport.encode(
      'current_actor' => {
        'uuid' => '1234',
        'name' => 'Remote Dude'
      }
    )

    agreement = described_class.parse(json)
    expect(agreement.current_actor).to_not be_nil
    expect(agreement.current_actor.uuid).to eq('1234')
    expect(agreement.current_actor.name).to eq('Remote Dude')
  end

end
