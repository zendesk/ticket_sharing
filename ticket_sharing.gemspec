Gem::Specification.new 'ticket_sharing', '1.2.0' do |s|
  s.authors = ['Josh Lubaway']
  s.email = 'josh@zendesk.com'
  s.extra_rdoc_files = ['Readme.md']
  s.files = Dir['lib/**/*']
  s.rdoc_options = ['--main', 'Readme.md']
  s.summary = 'Ticket sharing'
  s.description = 'A ruby implementation of the Networked Help Desk API'
  s.homepage = 'https://github.com/zendesk/ticket_sharing'
  s.license = 'Apache License Version 2.0'

  s.required_ruby_version = '>= 2.1.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'bump'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'faraday'

end
