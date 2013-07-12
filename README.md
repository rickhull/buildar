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
*     `publish` - `built` gem push
*     `buildar` - config check

Aux
*   `pre_build` - invoke `test` and `bump:build` conditionally
*       `built` - `build` conditionally
*     `install` - `built` gem install .gem
* `install_new` - `build` install built .gem
*     `version` - show the current project version

With git integration
*     `tag` - `message` git tag current version, push to origin
* `message` - capture a message from ENV['message'] or prompt STDIN

With version file integration
* `bump:build` - increment the 4th version number (1.2.3.4 -> 1.2.3.5)
* `bump:patch` - increment the 3rd version number (1.2.3.4 -> 1.2.4.0)
* `bump:minor` - increment the 2nd version number (1.2.3.4 -> 1.3.0.0)
* `bump:major` - increment the 1st version number (1.2.3.4 -> 2.0.0.0)
* `release:patch` - `bump:patch` `release`
* `release:minor` - `bump:minor` `release`
* `release:major` - `bump:major` `release`

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
require 'buildar'

Buildar.new do |b|
  b.gemspec_file = 'example.gemspec'
end
```

That is basically the minimal Rakefile needed for Buildar to operate, assuming you have a valid gemspec file named `example.gemspec`.

```
$ rake release
gem build example.gemspec
WARNING:  no email specified
Successfully built RubyGem
Name: example
Version: 1.2.3
File: example-1.2.3.gem
mv buildar-1.2.3.gem pkg/example-2.0.1.1.gem
gem push pkg/example-1.2.3.gem
Pushing gem to https://rubygems.org...
Successfully registered gem: example (1.2.3)
```


Here is Buildar's rakefile.rb:
```ruby
require 'buildar'

Buildar.new do |b|
  b.gemspec_file = 'buildar.gemspec'
  b.version_file = 'VERSION'
  b.use_git      = true
end
```

With b.version_file and b.use_git

`rake release:patch message="added version task; demonstrating Usage"`

```
bumping 2.0.0.9 to 2.0.1.0
git commit VERSION -m "Buildar version:bump_patch to 2.0.1.0"
[master 5df1ff8] Buildar version:bump_patch to 2.0.1.0
1 file changed, 1 insertion(+), 1 deletion(-)
bumping 2.0.1.0 to 2.0.1.1
git commit VERSION -m "Buildar version:bump_build to 2.0.1.1"
[master 73d9bdb] Buildar version:bump_build to 2.0.1.1
1 file changed, 1 insertion(+), 1 deletion(-)
gem build buildar.gemspec
WARNING:  no email specified
Successfully built RubyGem
Name: buildar
Version: 2.0.1.1
File: buildar-2.0.1.1.gem
mv buildar-2.0.1.1.gem pkg/buildar-2.0.1.1.gem
gem push pkg/buildar-2.0.1.1.gem
Pushing gem to https://rubygems.org...
Successfully registered gem: buildar (2.0.1.1)
git tag -a "v2.0.1.1" -m "added version task; demonstrating Usage"
git push origin --tags
To https://github.com/rickhull/buildar.git
* [new tag]         v2.0.1.1 -> v2.0.1.1
```

Without a gemspec file
----------------------
```ruby
Buildar.new do |b|
  b.gemspec.name = 'example'
  b.gemspec.summary  = 'Example of foo lorem ipsum'
  b.gemspec.author   = 'Buildar'
  b.gemspec.license  = 'MIT'
  b.gemspec.description = 'Foo bar baz quux'
  b.gemspec.files = ['Rakefile']
  b.gemspec.version = 1.2.3
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

Buildar will be able to `bump:major` `bump:minor` `bump:patch` and `bump:build`.  This helps with a repeatable, identifiable builds: `build` depends on `bump:build` etc.

Every build bumps the build number.  Since the build operates off of your potentially dirty working copy, and not some commit SHA, there is no guarantee that things haven't changed between builds, even if "nothing is supposed to have changed".  This guarantees that you can't have 2 builds floating around with the same version number but different contents.

Typically you'll want to let Buildar manage the build number, and you manage the major, minor, and patch numbers with:
* `release:major` - `bump:major`
* `release:minor` - `bump:minor`
* `release:patch` - `bump:patch`

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
