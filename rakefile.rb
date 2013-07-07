require 'buildar/tasks'
require 'rake/testtask'

Buildar.conf(__FILE__) do |b|
  b.use_version_file  = true
  b.version_filename  = 'VERSION'
  b.use_manifest_file = true
  b.manifest_filename = 'MANIFEST.txt'
  b.gemspec.name      = 'buildar'
  b.gemspec.summary   = 'Buildar crept inside your rakefile and scratched upon the tasking post'
  b.gemspec.description = <<EOF
Buildar helps automate the release process with versioning, building, packaging, and publishing.  Optional git integration.
EOF
  b.gemspec.author   = 'Rick Hull'
  b.gemspec.homepage = 'https://github.com/rickhull/buildar'
  b.gemspec.license  = 'MIT'
  b.gemspec.has_rdoc = true
  b.gemspec.add_runtime_dependency        "rake", ">= 5" # guess?
  b.gemspec.add_development_dependency "buildar", "~> 1.0"
end

Rake::TestTask.new :test do |t|
  t.pattern = 'test/*.rb'
end
