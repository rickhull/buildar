Buildar
=======
Buildar is a set of Rakefile methods and tasks to help automate versioning,
packaging, releasing, and publishing ruby gems.

Rake tasks
----------
* version - show the current project version (./VERSION)
* manifest - show the files tracked by the gem (./MANIFEST.txt)
* tag - git tag according to current version, pushed to origin
* bump_build - increment the 4th version number (1.2.3.4 -> 1.2.3.5)
* bump_patch - increment the 3rd version number (1.2.3.4 -> 1.2.4.0)
* bump_minor - increment the 2nd version number (1.2.3.4 -> 1.3.0.0)
* bump_major - increment the 1st version number (1.2.3.4 -> 2.0.0.0)
* build - bump_build, build a .gem file inside pkg/
* publish - gem push
* release - build, tag, publish
* release_patch - bump_patch, release
* release_minor - bump_minor, release
* release_major - bump_major, release
* test - from 'rake/testtask'

Philosophy
----------
* Track the release version in one place: ./VERSION
* The version only matters in the context of a release.  For internal development, git SHAs vastly outclass version numbers.
* "The right version number" for the next release is a function of the current release version and the magnitude (or breakiness) of the change
* http://semver.org/
* Automate everything
* This does not absolve you from attentending to changelogs, etc.

Using Buildar
-------------
Install it, using sudo as necessary:

    gem install buildar

Unpack the gem (a new directory will be created)

    gem unpack buildar

A directory like buildar-0.0.4.1 will be created in your CWD with three files:
* rakefile.rb
* VERSION
* MANIFEST.txt

Copy the rakefile.rb contained within to the root directory of the project you want to use it in.  Consider renaming any existing project Rakefile beforehand.  Consider copying VERSION and MANIFEST.txt as well, though note that these files will be specific to buildar itself.

Bbuildar creates your gemspec dynamically, and it relies on being able to find and read VERSION and MANIFEST.txt.  If you have different names for these files in your project, you can easily edit the top of the rakefile.rb.

Buildar will keep your VERSION file updated, but it's up to you to make sure MANIFEST.txt is up to date.  There is intentionally no support for globs.  Just list all the files you want included in the resulting gem.

Integrating rakefile.rb
-----------------------
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

Testing it out
--------------
    rake version  # print the version according to VERSION
    rake manifest # likewise for MANIFEST.txt
    rake bump     # bump the patch number in VERSION (1.2.3.4 -> 1.2.4.0)
    rake build    # build a .gem file in pkg/
    rake release  # build the .gem and push it rubygems.org

`rake release` depends on :verify_publish_credentials, which will fail if you don't have ~/.gem/credentials.  In that case, sign up for an account at http://rubygems.org/ and follow the instructions to get your credentials file setup.
