require './lib/ticket_sharing/version'

Gem::Specification.new 'ticket_sharing' do |s|
  s.version = TicketSharing::VERSION
  s.authors = ['Josh Lubaway']
  s.email = 'josh@zendesk.com'
  s.extra_rdoc_files = ['Readme.md']
  s.files = Dir['lib/**/*']
  s.rdoc_options = ['--main', 'Readme.md']
  s.summary = 'Ticket sharing'
  s.description = 'A ruby implementation of the Networked Help Desk API'
  s.homepage = 'https://github.com/zendesk/ticket_sharing'
  s.license = 'Apache License Version 2.0'

  s.required_ruby_version = '>= 3.2.0'

  s.add_dependency 'faraday', '>= 2.14.1'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'webmock', '>= 3.18.0'
  s.add_development_dependency 'rspec', '>= 3.12'
  s.add_development_dependency 'rexml', '>= 3.4.2'
end
