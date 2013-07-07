Buildar
=======
Buildar provides a set of rake tasks to help automate versioning, packaging, releasing, and publishing ruby gems, with optional git integration.

Rake tasks
----------
* `release` - `message` `build` `tag` `publish`
* `build` - `test` `bump_build` build a .gem file inside pkg/
* `test` - runs your tests using rake/testtask
* `publish` - `verify publish credentials` gem push
* `tag` - `test` git tag according to current version, pushed to origin
* `message` - capture a message from ENV['message'] or prompt STDIN
* `manifest` - show the files tracked by the gem (./MANIFEST.txt)
* `version` - show the current project version (./VERSION)
* `bump_build` - increment the 4th version number (1.2.3.4 -> 1.2.3.5)
* `bump_patch` - increment the 3rd version number (1.2.3.4 -> 1.2.4.0)
* `bump_minor` - increment the 2nd version number (1.2.3.4 -> 1.3.0.0)
* `bump_major` - increment the 1st version number (1.2.3.4 -> 2.0.0.0)
* `release_patch` - `bump_patch` `release`
* `release_minor` - `bump_minor` `release`
* `release_major` - `bump_major` `release`

Philosophy
----------
* Track the release version in one place: a version file freely readable and writable
* The version only matters in the context of a release.  For internal development, git SHAs vastly outclass version numbers.
* "The right version number" for the next release is a function of the current release version and the magnitude (or breakiness) of the change
* http://semver.org/
* Automate everything
* This does not absolve you from attentending to changelogs, etc.

Install
-------
    $ gem install buildar     # sudo as necessary

Usage
-----
Edit your Rakefile.  Add to the top:

    require 'buildar/tasks'

    Buildar.conf(__FILE__) do |b|
      # ...
    end

    # make sure you have a task named :test, even if it's empty
    task :test do
	  # ...
    end

That is actually the minimal Rakefile needed for Buildar to operate.  However, this would generate a crappy gem full of "FIX" throughout its metadata.

Dogfood
-------
Here is Buildar's [rakefile.rb](https://github.com/rickhull/buildar/blob/master/rakefile.rb):

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

You can use it as a starting point.

The default gemspec
-------------------
    def gemspec
      @gemspec ||= Gem::Specification.new do |s|
        # Static assignments
        s.summary     = "FIX"
        s.description = "FIX"
        s.authors     = ["FIX"]
        s.email       = "FIX@FIX.COM"
        s.homepage    = "http://FIX.COM/"
        s.licenses    = ['FIX']
        # s.has_rdoc    = true
        # s.test_files  = ['FIX']

        s.add_development_dependency     "rake", [">= 0"]
        s.add_development_dependency  "buildar", ["~> 1.0"]
      end
      # Make sure things tracked elsewhere stay updated
      @gemspec.name = @name
      @gemspec.files = self.manifest if @use_manifest_file
      @gemspec.version = self.version
      @gemspec
    end

The maximal configuration
---------------------
    Buildar.conf(__FILE__) do |b|
      # Buildar options
      b.root = '/path/to/project'
	  b.name = 'Project'
	  b.version_filename = 'VERSION.txt'
	  b.use_manifest_file = true
	  b.manifest_filename = 'MANIFEST'
	  b.use_git = true
	  b.publish[:rubygems] = true

	  # Gemspec Options
	  b.gemspec.author = 'Yours Truly'
	  #        ...
	  b.gemspec.version = '2.0'
	end

Git integration
---------------
Disable git integration by `b.use_git = false` if you're not interested in any of the following:

* `tag` is a `release` dependency.  It depends on `message` and `test`
* `bump` and friends will commit VERSION changes

Disabling git integration will not cause any tasks to fail.

Testing it out
--------------
    rake version  # print the version according to VERSION
    rake manifest # likewise for MANIFEST.txt
    rake bump     # bump the patch number in VERSION (1.2.3.4 -> 1.2.4.0)
    rake build    # build a .gem file in pkg/
    rake release  # build the .gem and push it rubygems.org

`rake release` depends on `verify_publish_credentials` which will fail if you don't have `~/.gem/credentials`.  In that case, sign up for an account at http://rubygems.org/ and follow the instructions to get your credentials file setup.

MANIFEST
--------
Track what you want included in the gem:

    b.manifest_filename = 'MANIFEST'

	### OR ###

	b.use_manifest_file = false
	b.gemspec.files = %w{ rakefile.rb }


Notes
-----
Buildar's dynamically generated gemspec relies on being able to find and read VERSION and MANIFEST.txt.  Buildar will keep your VERSION file updated, but it's up to you to make sure MANIFEST.txt is up to date.  There is intentionally no support for globs.  Just list all the files you want included in the resulting gem.
