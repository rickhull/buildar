Buildar
=======
Buildar is a set of Rakefile methods and tasks to help automate versioning,
packaging, releasing, and publishing ruby gems.

Rake tasks
----------
* version - show the current project version (./VERSION)
* manifest - show the files tracked by the gem (./MANIFEST.txt)
* build - build a .gem file
* bump_build - increment the 4th version number (1.2.3.4 -> 1.2.3.5)
* bump_patch - increment the 3rd version number (1.2.3.4 -> 1.2.4.0)
* bump_minor - increment the 2nd version number (1.2.3.4 -> 1.3.0.0)
* bump_major - increment the 1st version number (1.2.3.4 -> 2.0.0.0)
* tag - git tag according to current version, pushed to origin
* publish - gem push
* release - bump_build, tag, publish
* release_patch - bump_patch, tag, publish
* release_minor - bump_minor, tag, publish
* release_major - bump_major, tag, publish

Philosophy
----------
* Track the project version in one place: ./VERSION
* The version only matters in the context of a release.  For development purposes, git SHAs vastly outclass version numbers.
* "The right version number" for the next release is a function of the current release version and the magnitude (or breakiness) of the change
* http://semver.org/
* Automate everything
* This does not absolve you from attentending to changelogs, etc.
