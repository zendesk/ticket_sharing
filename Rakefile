require 'bundler/setup'
require 'bundler/gem_tasks'

# Pushing to rubygems is handled by a github workflow
ENV['gem_push'] = 'false'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: [:spec]
