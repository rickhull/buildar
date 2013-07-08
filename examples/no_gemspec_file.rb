require 'buildar/tasks'

Buildar.conf(__FILE__) do |b|
  b.name = 'Example'             # optional, inferred from directory
  b.use_gemspec_file = false
  b.use_version_file = false
  b.use_git = false
  b.publish[:rubygems] = false

  b.gemspec.summary  = 'Example of foo lorem ipsum'
  b.gemspec.author   = 'Buildar'
  b.gemspec.license  = 'MIT'
  b.gemspec.description = 'Foo bar baz quux'
  b.gemspec.files = ['Rakefile']

  # since b.use_version_file = false, maintain version here
  b.gemspec.version = 2.0
end

# make sure you have a task named :test, even if it's empty
task :test do
  # ...
end
