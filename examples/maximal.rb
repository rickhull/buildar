require 'buildar/tasks'

Buildar.conf(__FILE__) do |b|
  # Buildar options
  b.root = '/path/to/project'
  b.name = 'Project'
  b.use_version_file = true
  b.version_filename = 'VERSION.txt'
  b.use_manifest_file = true
  b.manifest_filename = 'MANIFEST'
  b.use_git = true
  b.publish[:rubygems] = true

  # Gemspec Options
  b.gemspec.author = 'Yours Truly'
  #        ...
  b.gemspec.version = '2.0'
end

task :test do
  # ...
end
