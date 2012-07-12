require 'test_helper'
require 'ticket_sharing/agreement'

class TicketSharing::AgreementTest < MiniTest::Unit::TestCase

  def test_should_initialize_with_attributes
    attributes = {
      'receiver_url' => 'http://example.com/sharing',
      'sender_url' => 'http://example.net/partners',
      'status' => 'pending',
      'sync_tags' => true,
      'sync_custom_fields' => true,
      'allows_public_comments' => true
    }

    agreement = TicketSharing::Agreement.new(attributes)

    assert_equal(attributes['receiver_url'], agreement.receiver_url)
    assert_equal(attributes['sender_url'], agreement.sender_url)
    assert_equal(attributes['status'], agreement.status)
    assert_equal(attributes['sync_tags'], agreement.sync_tags)
    assert_equal(attributes['sync_custom_fields'], agreement.sync_custom_fields)
    assert_equal(attributes['allows_public_comments'], agreement.allows_public_comments)
  end

  def test_should_generate_a_authentication_token
    attributes = {
      'uuid' => '<uuid>',
      'access_key' => '<access_key>'
    }
    agreement = TicketSharing::Agreement.new(attributes)
    assert_equal("<uuid>:<access_key>", agreement.authentication_token)
  end

  def test_should_marshal_from_json
    json = TicketSharing::JsonSupport.encode({
      'name' => 'Organization Foo',
      'uuid' => 'the_uuid',
      'access_key' => 'the_access_key',
      'receiver_url' => 'http://example.com/sharing',
      'sender_url' => 'http://example.net/partners',
      'status' => 'pending',
      'allows_public_comments' => true
    })

    agreement = TicketSharing::Agreement.parse(json)

    assert_equal('Organization Foo', agreement.name)
    assert_equal('the_uuid', agreement.uuid)
    assert_equal('the_access_key', agreement.access_key)
    assert_equal('http://example.com/sharing', agreement.receiver_url)
    assert_equal('http://example.net/partners', agreement.sender_url)
    assert_equal('pending', agreement.status)
    assert_equal(true, agreement.allows_public_comments)
  end

  def test_json_serialization
    agreement = TicketSharing::Agreement.new
    agreement.status = 'pending'

    json = agreement.to_json
    assert_match(/status/, json)
  end

  def test_should_serialize_and_deserialize
    attributes = {
      'name' => 'Organization Foo',
      'receiver_url' => 'http://example.com/sharing',
      'sender_url' => 'http://example.net/partners',
      'status' => 'pending'
    }
    agreement = TicketSharing::Agreement.new(attributes)

    json = agreement.to_json
    agreement2 = TicketSharing::Agreement.parse(json)

    assert_equal(agreement.name, agreement2.name)
    assert_equal(agreement.receiver_url, agreement2.receiver_url)
    assert_equal(agreement.sender_url, agreement2.sender_url)
    assert_equal(agreement.status, agreement2.status)
  end

  def test_should_send_to_partner
    attributes = {
      'receiver_url' => 'http://example.com/sharing',
      'uuid' => '5ad614f4'
    }

    agreement = TicketSharing::Agreement.new(attributes)
    FakeWeb.register_uri(:post,
      'http://example.com/sharing/agreements/5ad614f4', :body => '')

    assert agreement.send_to(attributes['receiver_url'])
  end

  def test_should_raise_when_unable_to_send_to_partner
    attributes = {
      'receiver_url' => 'http://example.com/sharing',
      'uuid' => '5ad614f4'
    }

    agreement = TicketSharing::Agreement.new(attributes)
    FakeWeb.register_uri(:post,
      'http://example.com/sharing/agreements/5ad614f4',
      :body => '', :status => [400, "Bad Request"])

    assert_raises(TicketSharing::Error) do
      agreement.send_to(attributes['receiver_url'])
    end
  end

  def test_should_update_partner
    FakeWeb.last_request = nil
    FakeWeb.register_uri(:put,
      'http://example.com/sharing/agreements/5ad614f4', :body => '')

    attributes = {
      'receiver_url' => 'http://example.com/sharing',
      'uuid' => '5ad614f4',
      'access_key' => 'APIKEY123'
    }

    agreement = TicketSharing::Agreement.new(attributes)
    assert agreement.update_partner(attributes['receiver_url'])

    request = FakeWeb.last_request
    assert_equal('/sharing/agreements/5ad614f4', request.path)
    assert_match(/5ad614f4/, request.body)
    assert_equal('5ad614f4:APIKEY123', request['X-Ticket-Sharing-Token'])
  end

  def test_should_deserialize_current_actor
    json = TicketSharing::JsonSupport.encode({
      'current_actor' => {
        'uuid' => '1234',
        'name' => 'Remote Dude'
      }
    })

    agreement = TicketSharing::Agreement.parse(json)
    assert !agreement.current_actor.nil?
    assert_equal('1234', agreement.current_actor.uuid)
    assert_equal('Remote Dude', agreement.current_actor.name)
  end

end
