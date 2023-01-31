Gem::Specification.new do |s|
  # static stuff
  s.name     = 'buildar'
  s.summary  = 'Buildar adds rake tasks to assist with gem publishing'
  s.author   = 'Rick Hull'
  s.homepage = 'https://github.com/rickhull/buildar'
  s.license  = 'MIT'
  s.description = 'Buildar helps automate the release process with versioning, building, packaging, and publishing.  Optional git integration.'

  s.required_ruby_version = ">= 2"

  # dynamic assignments
  s.version  = File.read(File.join(__dir__, 'VERSION')).chomp
  s.files =
    File.readlines(File.join(__dir__, 'MANIFEST.txt')).map { |f| f.chomp }
end
