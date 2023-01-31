Gem::Specification.new do |s|
  # static stuff
  s.name     = 'buildar'
  s.summary  = 'Buildar adds rake tasks to assist with gem publishing'
  s.author   = 'Rick Hull'
  s.homepage = 'https://github.com/rickhull/buildar'
  s.license  = 'MIT'
  s.description = 'Buildar helps automate the release process with versioning, building, packaging, and publishing.  Optional git integration.'

  s.required_ruby_version = ">= 2"

  s.version  = File.read(File.join(__dir__, 'VERSION')).chomp
  s.files  = %w[buildar.gemspec VERSION README.md Rakefile]
  s.files += Dir['lib/**/*.rb']
  s.files += Dir['test/**/*.rb']
end
