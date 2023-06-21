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

    expect(agreement.receiver_url)          .must_equal(attributes['receiver_url'])
    expect(agreement.sender_url)            .must_equal(attributes['sender_url'])
    expect(agreement.status)                .must_equal(attributes['status'])
    expect(agreement.sync_tags)             .must_equal(attributes['sync_tags'])
    expect(agreement.sync_custom_fields)    .must_equal(attributes['sync_custom_fields'])
    expect(agreement.allows_public_comments).must_equal(attributes['allows_public_comments'])
  end

  it 'generates a authentication token' do
    attributes = {
      'uuid'       => '<uuid>',
      'access_key' => '<access_key>'
    }
    agreement = described_class.new(attributes)
    expect(agreement.authentication_token).must_equal("<uuid>:<access_key>")
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

    expect(agreement.name)                  .must_equal('Organization Foo')
    expect(agreement.uuid)                  .must_equal('the_uuid')
    expect(agreement.access_key)            .must_equal('the_access_key')
    expect(agreement.receiver_url)          .must_equal('http://example.com/sharing')
    expect(agreement.sender_url)            .must_equal('http://example.net/partners')
    expect(agreement.status)                .must_equal('pending')
    expect(agreement.allows_public_comments).must_equal(true)
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

    expect(agreement2.name)        .must_equal(agreement.name)
    expect(agreement2.receiver_url).must_equal(agreement.receiver_url)
    expect(agreement2.sender_url)  .must_equal(agreement.sender_url)
    expect(agreement2.status)      .must_equal(agreement.status)
  end

  it 'sends to partner' do
    attributes = {
      'receiver_url' => 'http://example.com/sharing',
      'uuid'         => '5ad614f4'
    }

    agreement = described_class.new(attributes)
    stub_request(:post, 'http://example.com/sharing/agreements/5ad614f4')

    expect(!!agreement.send_to(attributes['receiver_url'])).must_equal true
  end

  it 'raises when unable to send to partner' do
    attributes = {
      'receiver_url' => 'http://example.com/sharing',
      'uuid'         => '5ad614f4'
    }

    agreement = described_class.new(attributes)
    stub_request(:post, 'http://example.com/sharing/agreements/5ad614f4')
      .to_return(status: 400)

    expect {
      agreement.send_to(attributes['receiver_url'])
    }.must_raise(TicketSharing::Error)
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
    expect(!!agreement.update_partner(attributes['receiver_url'])).must_equal true
  end

  it 'deserializes current actor' do
    json = TicketSharing::JsonSupport.encode(
      'current_actor' => {
        'uuid' => '1234',
        'name' => 'Remote Dude'
      }
    )

    agreement = described_class.parse(json)
    expect(agreement.current_actor).wont_be_nil
    expect(agreement.current_actor.uuid).must_equal('1234')
    expect(agreement.current_actor.name).must_equal('Remote Dude')
  end

end
