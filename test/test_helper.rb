require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/rg'
require 'minitest/spec'
require 'fakeweb'
require 'mocha/setup'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

FakeWeb.allow_net_connect = false
