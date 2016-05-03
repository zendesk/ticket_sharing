require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/rg'
require 'minitest/spec'
require 'webmock/minitest'
require 'mocha/setup'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
