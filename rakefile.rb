require 'buildar'

Buildar.new do |b|
  b.gemspec_file = 'buildar.gemspec'
  b.version_file = 'VERSION'
  b.use_git      = true
end
