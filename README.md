Buildar
=======
Buildar provides a set of rake tasks to help automate releasing your gem:
* Versioning
* Building / Packaging
* Publishing

With a set of options to integrate with your current project.

Rake tasks
----------
Core
*     `release` - `build` `publish` `tag`
*       `build` - `pre_build` gem build a pkg/.gem
* `gem_package` - `pre_build` Gem::PackageTask builds a pkg/.gem
*     `install` - `built` install built .gem
* `install_new` - `build` install built .gem
*     `version` - show the current project version
*     `buildar` - config check
*     `message` - capture a message from ENV['message'] or prompt STDIN
*   `pre_build` - invoke `test` and `bump_build` conditionally
*     `publish` - `built` gem push
*         `tag` - `message` git tag according to current version, pushed to origin

With version file integration
* `bump_build` - increment the 4th version number (1.2.3.4 -> 1.2.3.5)
* `bump_patch` - increment the 3rd version number (1.2.3.4 -> 1.2.4.0)
* `bump_minor` - increment the 2nd version number (1.2.3.4 -> 1.3.0.0)
* `bump_major` - increment the 1st version number (1.2.3.4 -> 2.0.0.0)
* `release_patch` - `bump_patch` `release`
* `release_minor` - `bump_minor` `release`
* `release_major` - `bump_major` `release`

Tasks which depend on optional functionality will not fail if the option is disabled.  They are effectively skipped.

[Just show me the tasks](https://github.com/rickhull/buildar/blob/master/lib/buildar.rb#L73)

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
  # ...
end

# make sure you have a task named :test, even if it's empty
task :test do
  # ...
end
```

That is basically the minimal Rakefile needed for Buildar to operate, assuming you have a valid gemspec file named `Example.gemspec`.

Without a gemspec file
----------------------
```ruby
Buildar.conf(__FILE__) do |b|
  b.name = 'Example'
  b.use_gemspec_file = false
  b.use_version_file = false
  b.use_git = false
  b.publish[:rubygems] = false

  b.gemspec.summary  = 'Example of foo lorem ipsum'
  b.gemspec.author   = 'Buildar'
  b.gemspec.license  = 'MIT'
  b.gemspec.description = 'Foo bar baz quux'
  b.gemspec.files = ['Rakefile']
  b.gemspec.version = 2.0
end
```
From [examples/no_gemspec_file.rb](https://github.com/rickhull/buildar/blob/master/examples/no_gemspec_file.rb)

Someone told me this breaks [Bundler](https://github.com/bundler/bundler), so maybe just use a gemspec file, k?

Dogfood
-------
Here is Buildar's [rakefile.rb](https://github.com/rickhull/buildar/blob/master/rakefile.rb):

```ruby
require 'buildar/tasks'
require 'rake/testtask'

Buildar.conf(__FILE__) do |b|
  b.name = 'buildar'
  b.use_version_file  = true
  b.version_filename  = 'VERSION'
  b.use_git           = true
  b.publish[:rubygems] = true
end

Rake::TestTask.new :test do |t|
  t.pattern = 'test/*.rb'
end
```

You can use it as a starting point.

Use a VERSION file
------------------
* Buildar can manage your version numbers with `b.use_version_file = true`
* The version only matters in the context of a release.  For internal development, git SHAs vastly outclass version numbers.
* "The right version number" for the next release is a function of the current release version and the magnitude (or breakiness) of the change
* http://semver.org/
* Automate everything

Enable and configure a version file:
```ruby
  b.use_version_file = true
  b.version_filename = 'VERSION'
```

The VERSION file should look something like
```
1.2.3.4
```

Buildar will be able to `bump_major` `bump_minor` `bump_patch` and `bump_build`.  This helps with a repeatable, identifiable builds: `build` depends on `bump_build` etc.

Every build bumps the build number.  Since the build operates off of your potentially dirty working copy, and not some commit SHA, there is no guarantee that things haven't changed between builds, even if "nothing is supposed to have changed".  Typically you'll want to let Buildar manage the build number, and you manage the major, minor, and patch numbers with:
* `release_major` - `bump_major`
* `release_minor` - `bump_minor`
* `release_patch` - `bump_patch`

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
    file = File.expand_path('../../VERSION', __FILE__)
	File.read(file).chomp
  end
end
```

If you stick with the default `b.use_version_file = false` then you need to make sure to keep your gemspec's version attribute updated.

Gemspec file tricks
-------------------
I like to let Buildar manage my [VERSION](https://github.com/rickhull/buildar/blob/master/VERSION) file, and I also like to maintain my [MANIFEST.txt](https://github.com/rickhull/buildar/blob/master/MANIFEST.txt) -- the canonical list of files belonging to the project -- outside of [buildar.gemspec](https://github.com/rickhull/buildar/blob/master/buildar.gemspec).

With
```ruby
Buildar.conf(__FILE__) do |b|
  b.use_gemspec_file = true
  b.use_version_file = true
```

You'll need to keep your gemspec file in synch with the version_file.  Here's [how Buildar does it](https://github.com/rickhull/buildar/blob/master/buildar.gemspec):
```ruby
# Gem::Specification.new do |s|
  # ...
  # dynamic setup
  this_dir = File.expand_path('..', __FILE__)
  version_file = File.join(this_dir, 'VERSION')
  manifest_file = File.join(this_dir, 'MANIFEST.txt')

  # dynamic assignments
  s.version  = File.read(version_file).chomp
  s.files = File.readlines(manifest_file).map { |f| f.chomp }
```

Integrate with git
------------------
Enable git integration with `b.use_git = true`.  This empowers `tag` and `bump`:
* `tag` is a `release` dependency.  It depends on `test` git tag -a $tagname -m $message
* `bump` and friends will commit VERSION changes

Publish to rubygems.org
-----------------------
Enable `publish` to rubygems.org with `b.publish[:rubygems] = true`.

Testing it out
--------------
```shell
rake buildar  # print Buildar's config / smoketest
rake version  # print the Buildar's understanding of the version
rake build    # build a .gem file in pkg/
rake install  # build, uninstall, install
rake release  # build the .gem and push it rubygems.org
```

`release` depends on `publish` which depends on `verify_publish_credentials` which will fail if you don't have `~/.gem/credentials`.  In that case, sign up for an account at http://rubygems.org/ and follow the instructions to get your credentials file setup.
