require 'buildar'

Buildar.new do |b|
  b.gemspec.name = 'example'
  b.gemspec.summary  = 'Example of foo lorem ipsum'
  b.gemspec.author   = 'Buildar'
  b.gemspec.license  = 'MIT'
  b.gemspec.description = 'Foo bar baz quux'
  b.gemspec.files = ['Rakefile']
  b.gemspec.version = '1.2.3'
end
