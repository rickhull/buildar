Buildar
=======
Buildar lives inside your Rakefile, consisting of a ruby module and a set of tasks to help automate versioning, packaging, releasing, and publishing ruby gems, with optional git integration.

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
* Track the release version in one place: `./VERSION`
* The version only matters in the context of a release.  For internal development, git SHAs vastly outclass version numbers.
* "The right version number" for the next release is a function of the current release version and the magnitude (or breakiness) of the change
* http://semver.org/
* Automate everything
* This does not absolve you from attentending to changelogs, etc.

Using Buildar
-------------
If you don't have a Rakefile, just start using Buildar's [rakefile.rb](https://github.com/rickhull/buildar/raw/master/rakefile.rb).  Otherwise, copy and paste Buildar's rakefile.rb into your Rakefile.  There may be some conflict over task names that you'll have to resolve.

Alternative methods of getting a hold of rakefile.rb:

    gem install buildar  # sudo as nec
    gem unpack buildar
    # a new directory is created, containing rakefile.rb

    ## OR ##

    git clone https://github.com/rickhull/buildar.git
    # a new directory is created, containing rakefile.rb

No matter what, you'll need to edit the top of Buildar's rakefile.rb to suit your own project.

Editing rakefile.rb
-------------------
There are only two sections you need to consider: the topmost section of the Buildar module that defines the constants and the .gemspec method, and the Rake::TestTask that defines where your test files live.

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

And the :test task:

    # task :test runs your test files
    #
    Rake::TestTask.new :test do |t|
      t.pattern = 'test/*.rb' # FIX for your layout
    end

Buildar's dynamically generated gemspec relies on being able to find and read VERSION and MANIFEST.txt.  Buildar will keep your VERSION file updated, but it's up to you to make sure MANIFEST.txt is up to date.  There is intentionally no support for globs.  Just list all the files you want included in the resulting gem.

Git integration
---------------
Set `USE_GIT = false` if you're not interested in any of the following:
* `tag` is a `release` dependency.  It depends on `test`
* `bump` and friends will commit VERSION changes `if USE_GIT and GIT_COMMIT_VERSION`
* `gitpush` simply does `git push origin`

Testing it out
--------------
    rake version  # print the version according to VERSION
    rake manifest # likewise for MANIFEST.txt
    rake bump     # bump the patch number in VERSION (1.2.3.4 -> 1.2.4.0)
    rake build    # build a .gem file in pkg/
    rake release  # build the .gem and push it rubygems.org

`rake release` depends on `verify_publish_credentials` which will fail if you don't have `~/.gem/credentials`.  In that case, sign up for an account at http://rubygems.org/ and follow the instructions to get your credentials file setup.
