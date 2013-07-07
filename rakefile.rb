require 'buildar/tasks'
require 'rake/testtask'

Buildar.conf(__FILE__) do |b|
  b.gemspec.name = 'buildar'
  b.gemspec.summary = 'Buildar crept inside your rakefile and scratched some tasks'
  b.gemspec.description = 'Buildar helps automate the release process with versioning, building, packaging, and publishing.  Optional git integration'
  b.gemspec.author = 'Rick Hull'
  b.gemspec.homepage = 'https://github.com/rickhull/buildar'
  b.gemspec.license = 'MIT'
  b.gemspec.has_rdoc = true
end

Rake::TestTask.new :test do |t|
  t.pattern = 'test/*.rb'
end
