require 'buildar/tasks'
require 'rake/testtask'

Buildar.conf(__FILE__) do |b|
  b.name = 'buildar'
  b.use_version_file  = true
  b.version_filename  = 'VERSION'
  b.use_manifest_file = true
  b.manifest_filename = 'MANIFEST.txt'
  b.use_git           = true
  b.publish[:rubygems] = true
end

Rake::TestTask.new :test do |t|
  t.pattern = 'test/*.rb'
end
