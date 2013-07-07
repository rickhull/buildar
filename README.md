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
* `install` - `test` `build` uninstall, install .gem
* `version` - show the current project version
* `manifest` - show the files tracked by the gem
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
```shell
$ gem install buildar     # sudo as necessary
```

Usage
-----
Edit your Rakefile.  Add to the top:

```ruby
require 'buildar/tasks'

Buildar.conf(__FILE__) do |b|
  b.name = 'Example'             # optional, inferred from directory
  b.gemspec.version = '1.0'      # required, unless b.use_version_file
  b.gemspec.files = ['Rakefile'] # required, unless b.use_manifest_file
  b.gemspec.summary = 'Summary'  # required
  b.gemspec.author = 'Buildar'   # required
end

# make sure you have a task named :test, even if it's empty
task :test do
  # ...
end
```

That is basically the [minimal Rakefile needed for Buildar to operate](https://github.com/rickhull/buildar/blob/master/examples/minimal.rb).  However, this would generate a skeleton gem not worth building or publishing.

Dogfood
-------
Here is Buildar's [rakefile.rb](https://github.com/rickhull/buildar/blob/master/rakefile.rb):

```ruby
require 'buildar/tasks'
require 'rake/testtask'

Buildar.conf(__FILE__) do |b|
  b.use_version_file  = true
  b.version_filename  = 'VERSION'
  b.use_manifest_file = true
  b.manifest_filename = 'MANIFEST.txt'
  b.use_git           = true
  b.publish[:rubygems] =  true
  b.gemspec.name     = 'buildar'
  b.gemspec.summary  = 'Buildar crept inside your rakefile and scratched upon the tasking post'
  b.gemspec.author   = 'Rick Hull'
  b.gemspec.homepage = 'https://github.com/rickhull/buildar'
  b.gemspec.license  = 'MIT'
  b.gemspec.has_rdoc = true
  b.gemspec.description = 'Buildar helps automate the release process with versioning, building, packaging, and publishing.  Optional git integration.'
  b.gemspec.add_runtime_dependency        "rake", ">= 8" # guess?
  b.gemspec.add_development_dependency "buildar", "~> 1.0"
end

Rake::TestTask.new :test do |t|
  t.pattern = 'test/*.rb'
end
```

You can use it as a starting point.

The maximal configuration
---------------------
```ruby
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
```

Use a VERSION file
------------------
Enable and configure a version file:
```ruby
  b.use_version_file = true
  b.version_filename = 'VERSION'
```

The VERSION file should look something like
```
1.2.3.4
```

Buildar will be able to `bump_major` `bump_minor` `bump_patch` and `bump_build`.  This helps with a repeatable release process:
* `build` depends on `bump_build` etc.
* `release` depends on `build` etc.
* `release_patch` depends on `bump_patch` `release` etc.

To make your app or lib aware of its version via this file, simply:

```ruby
# e.g. lib/foo.rb
#################
module Foo
  # use a method, not a constant like VERSION
  # if you use a constant, then you're doing an extra file read at requiretime
  # and that hurts production.  This method should not be called in production.
  # It's here more for deployment and sysadmin purposes.  Memoize as needed.
  #
  def self.version
    vpath = File.join(File.dirname(__FILE__), '..', 'VERSION')
	File.read(vpath).chomp
  end
end
```

If you stick with the default `b.use_version_file = false` then you need to make sure to keep the gemspec.version attribute updated.

Use a MANIFEST.txt file
-----------------------
It can be useful to track your project's files outside of your gemspec.  When enabled, Buildar will inject the contents of this file into your gemspec.files.
```ruby
  b.use_manifest_file
  b.manifest_filename = 'MANIFEST.txt'
```

Here is Buildar's [MANIFEST.txt](https://github.com/rickhull/buildar/blob/master/MANIFEST.txt)

    MANIFEST.txt
	VERSION
	rakefile.rb
	lib/buildar.rb
	lib/buildar/tasks.rb


You need to make sure this file stays up to date.  Buildar just reads it.

If you stick with the default `b.use_manifest_file = false` then you need to make sure to keep the gemspec.files attribute updated.

Integrate with git
------------------
Enable git integration with `b.use_git = true`.  This empowers `tag` and `bump`:
* `tag` is a `release` dependency.  It depends on `message` and `test`
* `bump` and friends will commit VERSION changes

Publish to rubygems.org
-----------------------
Enable rubygems.org publishing with `b.publish[:rubygems] = true`.  This empowers `publish`

Testing it out
--------------
```shell
rake version  # print the version according to VERSION
rake manifest # likewise for MANIFEST.txt
rake bump     # bump the patch number in VERSION (1.2.3.4 -> 1.2.4.0)
rake build    # build a .gem file in pkg/
rake release  # build the .gem and push it rubygems.org
```

`release` depends on `publish` which depends on `verify_publish_credentials` which will fail if you don't have `~/.gem/credentials`.  In that case, sign up for an account at http://rubygems.org/ and follow the instructions to get your credentials file setup.
