require 'buildar/tasks'

Buildar.conf(__FILE__) do |b|
  b.name = 'Example'             # optional, inferred from directory
  b.gemspec.version = '1.0'      # required, unless b.use_version_file
  b.gemspec.files = ['Rakefile'] # required, unless b.use_manifest_file
  b.gemspec.summary = 'Summary'  # required
  b.gemspec.author = 'Buildar'   # required
end

# make sure you have a task named :test, even if it's empty
task :test do
  # ...
end
