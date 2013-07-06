Buildar
=======
Buildar is a set of Rakefile methods and tasks to help automate versioning,
packaging, releasing, and publishing ruby gems, with optional git integration.

Rake tasks
----------
* `release` - `message` `build` `tag` `publish`
* `build` - `test` `bump_build` build a .gem file inside pkg/
* `test` - runs your tests using rake/testtask
* `publish` - `verify publish credentials` gem push
* `tag` - git tag according to current version, pushed to origin
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
Just integrate Buildar's [rakefile.rb](https://github.com/rickhull/buildar/raw/master/rakefile.rb) with your project's metadata and existing Rakefile.  For the Rakefile, hopefully nothing conflicts, and you can just paste Buildar's rakefile.rb at the top.

Alternative methods of getting a hold of rakefile.rb:

    gem install buildar  # sudo as nec
    gem unpack buildar
    # a new directory is created, containing rakefile.rb

    ## OR ##

    git clone https://github.com/rickhull/buildar.git
    # a new directory is created, containing rakefile.rb

Buildar creates your gemspec dynamically, and it relies on being able to find and read VERSION and MANIFEST.txt.  If you have different names for these files in your project, you can easily edit the top of the rakefile.rb.

Buildar will keep your VERSION file updated, but it's up to you to make sure MANIFEST.txt is up to date.  There is intentionally no support for globs.  Just list all the files you want included in the resulting gem.

Editing rakefile.rb
-------------------
We need to make a few edits to the rakefile.rb to match your project:

    Rake::TestTask.new :test do |t|
      # FIX for your layout
      t.pattern = 'test/*.rb'
    end

Buildar will infer the project name from the directory that contains the rakefile.rb.  You can set it directly instead, by editing the 2nd line:

    PROJECT_ROOT = File.dirname(__FILE__)
    PROJECT_NAME = File.split(PROJECT_ROOT).last

Likewise, if you use different filenames for your version and manifests:

    VERSION_FILE = File.join(PROJECT_ROOT, 'VERSION')
    MANIFEST_FILE = File.join(PROJECT_ROOT, 'MANIFEST.txt')

Next, find the :build task.  You'll want to edit in the static parts of your gemspec:

      spec = Gem::Specification.new do |s|
        # Static assignments
        s.name        = PROJECT_NAME
        s.summary     = "FIX"
        s.description = "FIX"
        s.authors     = ["FIX"]
        s.email       = "FIX@FIX.COM"
        s.homepage    = "http://FIX.COM/"
        s.licenses    = ['FIX']

As well as your dependencies:

    #    s.add_runtime_dependency  "rest-client", ["~> 1"]
    #    s.add_runtime_dependency         "json", ["~> 1"]
        s.add_development_dependency "minitest", [">= 0"]
        s.add_development_dependency     "rake", [">= 0"]

Git integration
---------------
`USE_GIT = false` if you're not interested in any of the following:
* [task :tag](https://github.com/rickhull/buildar/blob/master/rakefile.rb#L24) is a [task :release](https://github.com/rickhull/buildar/blob/master/rakefile.rb#L136) dependency.  It depends on [task :test](https://github.com/rickhull/buildar/blob/master/rakefile.rb#L4).
* The [:bump_* tasks](https://github.com/rickhull/buildar/blob/master/rakefile.rb#L91) will commit VERSION changes if USE_GIT and GIT_COMMIT_VERSION
* [task :gitpush](https://github.com/rickhull/buildar/blob/master/rakefile.rb#L128) simply does `git push origin`

Testing it out
--------------
    rake version  # print the version according to VERSION
    rake manifest # likewise for MANIFEST.txt
    rake bump     # bump the patch number in VERSION (1.2.3.4 -> 1.2.4.0)
    rake build    # build a .gem file in pkg/
    rake release  # build the .gem and push it rubygems.org

`rake release` depends on :verify_publish_credentials, which will fail if you don't have `~/.gem/credentials`.  In that case, sign up for an account at http://rubygems.org/ and follow the instructions to get your credentials file setup.
