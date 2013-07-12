require 'buildar'

Buildar.new do |b|
  b.version_file = 'VERSION'
  b.gemspec.name = 'example'
  b.gemspec.summary  = 'Example of foo lorem ipsum'
  b.gemspec.author   = 'Buildar'
  b.gemspec.license  = 'MIT'
  b.gemspec.description = 'Foo bar baz quux'
  b.gemspec.files = ['Rakefile']
end
