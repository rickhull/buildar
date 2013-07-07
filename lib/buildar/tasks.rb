require 'buildar'
require 'rubygems/package_task'

# shortcut to Buildar's data from the project rakefile
#
def proj
  Buildar.instance
end

# the reason you're here
#
task :release => [:message, :build, :tag, :publish]

# these are handy
#
task :release_patch => [:bump_patch, :release]
task :release_minor => [:bump_minor, :release]
task :release_major => [:bump_major, :release]

# make sure ENV['message'] is populated
#
task :message do
  unless ENV['message']
    print "This task requires a message:\n> "
    ENV['message'] = $stdin.gets.chomp
  end
end

# roughly equivalent to `gem build foo.gemspec`
# places .gem file in pkg/
#
task :build => [:test, :bump_build] do
  # definine the task at runtime, rather than requiretime
  # so that the gemspec will reflect any version bumping since requiretime
  Gem::PackageTask.new(proj.gemspec).define
  Rake::Task["package"].invoke
end

# tasks :bump_major, :bump_minor, :bump_patch, :bump_build
# commit the version file if proj.use_git
#
[:major, :minor, :patch, :build].each { |v|
  task "bump_#{v}" do
    old_version = proj.version
    new_version = Buildar.bump(v, old_version)
    puts "bumping #{old_version} to #{new_version}"
    proj.write_version new_version
    if proj.use_git
      msg = "rake bump_#{v} to #{new_version}"
      sh "git commit #{proj.version_file} -m '#{msg}'"
    end
  end
}

# if proj.use_git:
# create annotated git tag based on VERSION and ENV['message'] if available
# push tags to origin
#
task :tag => [:test] do
  if proj.use_git
    tagname = "v#{proj.version}"
    message = ENV['message'] || "auto-tagged #{tagname} by Rake"
    sh "git tag -a '#{tagname}' -m '#{message}'"
    sh "git push origin --tags"
  end
end

# roughly, gem push foo-VERSION.gem
#
task :publish => [:verify_publish_credentials] do
  if proj.publish[:rubygems]
    fragment = "-#{proj.version}.gem"
    pkg_dir = File.join(proj.root, 'pkg')
    Dir.chdir(pkg_dir) {
      candidates = Dir.glob "*#{fragment}"
      # sanity check
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

# just make sure the ~/.gem/credentials file is readable
#
task :verify_publish_credentials do
  if proj.publish[:rubygems]
    creds = '~/.gem/credentials'
    fp = File.expand_path(creds)
    raise "#{creds} does not exist" unless File.exists?(fp)
    raise "can't read #{creds}" unless File.readable?(fp)
  end
end

# display project name and version
#
task :version do
  puts "#{proj.name} #{proj.version}"
end

# display Buildar's understanding of the manifest file
#
task :manifest do
  puts proj.manifest.join("\n") if proj.use_manifest_file
end

# if the user wants a bump, make it a patch
#
task :bump => [:bump_patch]
