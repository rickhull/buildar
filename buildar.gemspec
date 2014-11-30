Gem::Specification.new do |s|
  # static stuff
  s.name     = 'buildar'
  s.summary  = 'Buildar crept inside your Rakefile and scratched upon the tasking post'
  s.author   = 'Rick Hull'
  s.homepage = 'https://github.com/rickhull/buildar'
  s.license  = 'MIT'
  s.has_rdoc = true
  s.description = 'Buildar helps automate the release process with versioning, building, packaging, and publishing.  Optional git integration.'

  s.add_runtime_dependency        "rake", ">= 8" # guess?

  # dynamic setup
  this_dir = File.expand_path('..', __FILE__)
  version_file = File.join(this_dir, 'VERSION')
  manifest_file = File.join(this_dir, 'MANIFEST.txt')

  # dynamic assignments
  s.version  = File.read(version_file).chomp
  s.files = File.readlines(manifest_file).map { |f| f.chomp }
end
