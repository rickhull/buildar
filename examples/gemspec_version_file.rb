require 'buildar/tasks'

Buildar.conf(__FILE__) do |b|
  b.name = 'Example'             # optional, inferred from directory
  b.use_gemspec_file = true
  b.use_version_file = true
  b.use_git = false
  b.publish[:rubygems] = false

  # since b.use_version_file = true
  b.version_filename = 'VERSION'

  # Buildar will keep the VERSION file updated.
  # It's up to you to make sure your gemspec file stays synched
  # see README.md, Gemspec file tricks, to do this automatically
end

# make sure you have a task named :test, even if it's empty
task :test do
  # ...
end
