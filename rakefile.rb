require 'buildar/tasks'

Buildar.conf(__FILE__) do |b|
  b.version_filename = 'VERSION'
  b.manifest_filename = 'MANIFEST.txt'
  b.use_git = true
  b.publish[:rubygems] = true
  b.gemspec.name = 'buildar'
  b.gemspec.summary = 'Buildar crept inside your rakefile and scratched some tasks'
  b.gemspec.description = 'Buildar helps automate the release process with versioning, building, packaging, and publishing.  Optional git integration'
  b.gemspec.author = 'Rick Hull'
  b.gemspec.homepage = 'https://github.com/rickhull/buildar'
  b.gemspec.license = 'MIT'
  b.gemspec.has_rdoc = true
end

require 'rake/testtask'
Rake::TestTask.new :test do |t|
  t.pattern = 'test/*.rb' # FIX for your layout
end
