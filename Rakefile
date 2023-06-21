require 'bundler/setup'
require 'bundler/gem_tasks'
require 'bump/tasks'
require 'rake/testtask'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: [:spec]

Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.libs << "test"
  t.verbose = true
  t.warning = true
end

task default: [:test]
