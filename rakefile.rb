require 'buildar/tasks'
require 'rake/testtask'

Buildar.conf(__FILE__) do |b|
  b.use_version_file  = true
  b.version_filename  = 'VERSION'
  b.use_manifest_file = true
  b.manifest_filename = 'MANIFEST.txt'
  b.use_git           = true
  b.publish[:rubygems] =  true
  b.gemspec.name     = 'buildar'
  b.gemspec.summary  = 'Buildar crept inside your rakefile and scratched upon the tasking post'
  b.gemspec.author   = 'Rick Hull'
  b.gemspec.homepage = 'https://github.com/rickhull/buildar'
  b.gemspec.license  = 'MIT'
  b.gemspec.has_rdoc = true
  b.gemspec.description = 'Buildar helps automate the release process with versioning, building, packaging, and publishing.  Optional git integration.'
  b.gemspec.add_runtime_dependency        "rake", ">= 8" # guess?
  b.gemspec.add_development_dependency "buildar", "~> 1.0"
end

Rake::TestTask.new :test do |t|
  t.pattern = 'test/*.rb'
end
