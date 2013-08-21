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
mv example-1.2.3.gem pkg/example-2.0.1.1.gem
gem push pkg/example-1.2.3.gem
Pushing gem to https://rubygems.org...
Successfully registered gem: example (1.2.3)
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
  b.gemspec.version = '1.2.3'
end
```

From [examples/no_gemspec_file.rb](https://github.com/rickhull/buildar/blob/master/examples/no_gemspec_file.rb)

Dogfood
-------
Here is Buildar's [rakefile.rb](https://github.com/rickhull/buildar/blob/master/rakefile.rb):

```ruby
require 'buildar'

Buildar.new do |b|
  b.gemspec_file = 'buildar.gemspec'
  b.version_file = 'VERSION'
  b.use_git      = true
end
```

With `b.version_file` and `b.use_git`

```
$ rake release:patch message="added version task; demonstrating Usage"
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

Use a VERSION file
------------------
* Buildar can manage your version numbers with `b.version_file`
* The version only matters in the context of a release.  For internal development, git SHAs vastly outclass version numbers.
* "The right version number" for the next release is a function of the current release version and the magnitude (or breakiness) of the change
* http://guides.rubygems.org/patterns/#semantic_versioning
* http://semver.org/
* Automate everything

The [VERSION](https://github.com/rickhull/buildar/blob/master/VERSION) file at your project root should look something like
```
1.2.3.4
```

Buildar will be able to `bump:major` `bump:minor` `bump:patch` and `bump:build`.  This helps with a repeatable, identifiable builds: `build` invokes `bump:build` etc.

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
  def self.version
    file = File.expand_path('../../VERSION', __FILE__)
	File.read(file).chomp
  end
end
```

`b.version_file` defaults to nil, so if you don't set it, you'll have to keep your gemspec's version attribute updated.

Gemspec file tricks
-------------------
With
```ruby
Buildar.new do |b|
  b.gemspec_file = 'example.gemspec'
  b.version_file = 'VERSION'
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

I also like to maintain a [MANIFEST.txt](https://github.com/rickhull/buildar/blob/master/MANIFEST.txt) -- the canonical list of files belonging to the project -- outside of the gemspec.
