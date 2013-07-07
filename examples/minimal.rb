require 'buildar/tasks'

Buildar.conf(__FILE__) do |b|
  b.use_version_file = false
  b.use_manifest_file = false
  b.gemspec.version = '0'
  b.gemspec.files = File.join(b.root, File.basename(__FILE__))
end

# make sure you have a task named :test, even if it's empty
task :test do
  # ...
end
