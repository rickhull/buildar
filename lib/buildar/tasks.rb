require 'buildar'

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
  if !ENV['message'] or ENV['message'].empty?
    print "This task requires a message:\n> "
    ENV['message'] = $stdin.gets.chomp
  end
end

# uses Gem::PackageTask to build via Gem API
# roughly equivalent to `gem build foo.gemspec`
# operates with a hard or soft gemspec
#
task :gem_package => [:test, :bump_build] do
  # definine the task at runtime, rather than requiretime
  # so that the gemspec will reflect any version bumping since requiretime
  require 'rubygems/package_task'
  Gem::PackageTask.new(proj.gemspec).define
  Rake::Task["package"].invoke
end

# if proj.use_gemspec_file
# exactly equiavlent to `gem build #{proj.gemspec_filename}`
# otherwise fall back to :gem_package
#
task :build => [:test, :bump_build] do
  if proj.use_gemspec_file
    sh "gem build #{proj.gemspec_filename}"
    target_file = "#{proj.name}-#{proj.available_version}.gem"
    if File.exists? target_file
      sh "mv #{target_file} pkg/#{target_file}"
    else
      puts "warning: expected #{target_file} but didn't find it"
    end
  else
    Rake::Task[:gem_package].invoke
  end
end

# build, install
#
task :install => [:build] do
  sh "gem install #{proj.gemfile}"
end

# if proj.use_version_file
# tasks :bump_major, :bump_minor, :bump_patch, :bump_build
# commit the version file if proj.use_git
#
[:major, :minor, :patch, :build].each { |v|
  task "bump_#{v}" do
    if proj.use_version_file
      old_version = proj.version
      new_version = Buildar.bump(v, old_version)
      puts "bumping #{old_version} to #{new_version}"
      proj.write_version new_version
      if proj.use_git
        msg = "rake bump_#{v} to #{new_version}"
        sh "git commit #{proj.version_file} -m '#{msg}'"
      end
    end
  end
}

# if proj.use_git
# create annotated git tag based on VERSION and ENV['message'] if available
# push tags to origin
#
task :tag => [:test] do
  if proj.use_git
    tagname = "v#{proj.available_version}"
    message = ENV['message'] || "auto-tagged #{tagname} by Rake"
    sh %Q{git tag -a "#{tagname}" -m "#{message}"}
    sh "git push origin --tags"
  end
end

# if proj.publish[:rubygems]
# roughly, gem push foo-VERSION.gem
#
task :publish => [:verify_publish_credentials] do
  sh "gem push #{proj.gemfile}" if proj.publish[:rubygems]
end

# if proj.publish[:rubygems]
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
  puts "#{proj.name} #{proj.available_version}"
end

# if the user wants a bump, make it a patch; not used internally
#
task :bump => [:bump_patch]

# config check
#
task :buildar do
  puts
  puts <<EOF
          Project: #{proj.name} #{proj.version}
             Root: #{proj.root}
 Use gemspec file: #{proj.use_gemspec_file}
   Gemspec source: #{proj.gemspec_location}
 Use version file: #{proj.use_version_file}
   Version source: #{proj.version_location}
          Use git: #{proj.use_git}
          Publish: #{proj.publish.keys}
# using Buildar #{Buildar.version}
EOF
  puts
end
