require 'buildar/tasks'

Buildar.conf(__FILE__) do |b|
  b.name = 'Example'             # optional, inferred from directory
  b.use_gemspec_file = true
  b.use_version_file = false
  b.use_git = false
  b.publish[:rubygems] = false

  # since b.use_version_file = false, maintain version here
  b.gemspec.version = 2.0
end

# make sure you have a task named :test, even if it's empty
task :test do
  # ...
end
