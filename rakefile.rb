require 'rubygems/package_task'
require 'rake/testtask'

module Buildar
  ##############################################
  # Project-specific settings.  Edit as needed.
  #
  #
  PROJECT_ROOT = File.dirname(__FILE__)
  PROJECT_NAME = File.split(PROJECT_ROOT).last
  VERSION_FILE = File.join(PROJECT_ROOT, 'VERSION')
  MANIFEST_FILE = File.join(PROJECT_ROOT, 'MANIFEST.txt')

  USE_GIT = true
  GIT_COMMIT_VERSION = true   # commit version bump automatically
  PUBLISH = {
    rubygems: true,  # publish .gem to http://rubygems.org/
  }

  def self.gemspec
    Gem::Specification.new do |s|
      # Static assignments
      s.name        = PROJECT_NAME
      s.summary     = "FIX"
      s.description = "FIX"
      s.authors     = ["FIX"]
      s.email       = "FIX@FIX.COM"
      s.homepage    = "http://FIX.COM/"
      s.licenses    = ['FIX']

      # Dynamic assignments
      s.files       = manifest
      s.version     = version
      s.date        = Time.now.strftime("%Y-%m-%d")

      # s.add_runtime_dependency  "rest-client", ["~> 1"]
      # s.add_runtime_dependency         "json", ["~> 1"]
      s.add_development_dependency "minitest", [">= 0"]
      s.add_development_dependency     "rake", [">= 0"]
    end
  end
  #
  #
  # End project-specific settings.
  ################################

  def self.version
    File.read(VERSION_FILE).chomp
  end

  def self.manifest
    File.readlines(MANIFEST_FILE).map { |line| line.chomp }
  end

  def self.write_version new_version
    File.open(VERSION_FILE, 'w') { |f| f.write(new_version) }
  end

  # e.g. bump(:minor, '1.2.3') #=> '1.3.0'
  # only works for integers delimited by periods (dots)
  #
  def self.bump(position, version)
    pos = [:major, :minor, :patch, :build].index(position) || position
    places = version.split('.')
    raise "bad position: #{pos} (for version #{version})" unless places[pos]
    places.map.with_index { |place, i|
      if i < pos
        place
      elsif i == pos
        place.to_i + 1
      else
        0
      end
    }.join('.')
  end
end


#######
# Tasks
#
#


# task :test runs your test files
#
Rake::TestTask.new :test do |t|
  t.pattern = 'test/*.rb' # FIX for your layout
end

task :version do
  puts "#{Buildar::PROJECT_NAME} #{Buildar.version}"
end

task :message do
  unless ENV['message']
    puts "Enter a one-line message:"
    print "> "
    ENV['message'] = $stdin.gets.chomp
  end
end

task :tag => [:test] do
  if Buildar::USE_GIT
    message = ENV['message'] || "auto-tagged #{tagname} by Rake"
    sh "git tag -a 'v#{Buildar.version}' -m '#{message}'"
    sh "git push origin --tags"
  end
end

task :manifest do
  puts Buildar.manifest.join("\n")
end

task :build => [:test, :bump_build] do
  # we're definining the task at runtime, rather than requiretime
  # so that the gemspec will reflect any version bumping since requiretime
  #
  Gem::PackageTask.new(Buildar.gemspec).define
  Rake::Task["package"].invoke
end

[:major, :minor, :patch, :build].each { |v|
  task "bump_#{v}" do
    old_version = Buildar.version
    new_version = Buildar.bump(v, old_version)
    puts "bumping #{old_version} to #{new_version}"
    Buildar.write_version new_version
    if Buildar::USE_GIT and Buildar::GIT_COMMIT_VERSION
      sh "git add VERSION"
      sh "git commit -m 'rake bump_#{v} to #{new_version}'"
    end
  end
}
task :bump => [:bump_patch]

task :verify_publish_credentials do
  if Buildar::PUBLISH[:rubygems]
    creds = '~/.gem/credentials'
    fp = File.expand_path(creds)
    raise "#{creds} does not exist" unless File.exists?(fp)
    raise "can't read #{creds}" unless File.readable?(fp)
  end
end

task :publish => [:verify_publish_credentials] do
  if Buildar::PUBLISH[:rubygems]
    fragment = "-#{Buildar.version}.gem"
    pkg_dir = File.join(Buildar::PROJECT_ROOT, 'pkg')
    Dir.chdir(pkg_dir) {
      candidates = Dir.glob "*#{fragment}"
      case candidates.length
      when 0
        raise "could not find .gem matching #{fragment}"
      when 1
        sh "gem push #{candidates.first}"
      else
        raise "multiple candidates found matching #{fragment}"
      end
    }
  end
end

task :gitpush do
  # may prompt
  sh "git push origin" if Buildar::USE_GIT
  # this kills the automation
  # use key-based auth?
  # consider a timeout?
end

task :release => [:message, :build, :tag, :publish, :gitpush]

task :release_patch => [:bump_patch, :release]
task :release_minor => [:bump_minor, :release]
task :release_major => [:bump_major, :release]
