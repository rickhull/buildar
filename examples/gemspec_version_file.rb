require 'buildar'

Buildar.new do |b|
  b.gemspec_file = 'example.gemspec'
  b.version_file = 'VERSION'
end
