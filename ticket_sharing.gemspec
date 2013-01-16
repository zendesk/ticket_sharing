# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = 'ticket_sharing'
  s.version = '0.6.10'

  s.authors = ['Josh Lubaway']
  s.email = 'josh@zendesk.com'
  s.extra_rdoc_files = ['Readme.md']
  s.files = Dir['lib/**/*']
  s.rdoc_options = ['--main', 'README.md']
  s.require_paths = ['lib']
  s.rubygems_version = '1.5.2'
  s.summary = 'Ticket sharing'

  if s.respond_to? :specification_version then
    s.specification_version = 3
  end
end
