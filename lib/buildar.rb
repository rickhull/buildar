require 'rake'
require 'rake/clean'
require 'rake/tasklib'

class Buildar < Rake::TaskLib
  def self.version
    file = File.expand_path('../../VERSION', __FILE__)
    File.read(file).chomp
  end

  # e.g. bump(:minor, '1.2.3') #=> '1.3.0'
  # only works for versions consisting of integers delimited by periods (dots)
  #
  def self.bump(position, version)
    pos = [:major, :minor, :patch, :build].index(position) || position
    places = version.split('.')
    if places.length <= pos and pos <= places.length + 3
      # add zeroes to places up to pos
      # allows bump(:build, '0') #=> '0.0.0.1'
      places.length.upto(pos) { |i| places[i] = 0 }
    end
    raise "bad position: #{pos} (for version #{version})" unless places[pos]
    places.map.with_index { |place, i|
      if i < pos
        place
      elsif i == pos
        place.to_i + 1
      else
        0
      end
    }.join('.')
  end

  attr_accessor :gemspec_file, :version_file, :use_git, :pkg_dir, :ns

  def initialize
    @gemspec_file = nil
    @version_file = nil
    @use_git = false
    @pkg_dir = 'pkg'
    @ns = ''

    if block_given?
      yield self
      define
    end
  end

  def gemspec
    if @gemspec_file
      Gem::Specification.load @gemspec_file
    else
      @gemspec ||= Gem::Specification.new
      @gemspec.version = self.read_version if @version_file
      @gemspec
    end
  end

  def read_version
    raise "no @version_file" unless @version_file
    File.read(@version_file).chomp
  end

  def write_version(new_version)
    raise "no @version_file" unless @version_file
    File.open(@version_file, 'w') { |f| f.write(new_version) }
  end

  def gem_file
    File.join(@pkg_dir, "#{gemspec.name}-#{gemspec.version}.gem")
  end

  def define
    directory @pkg_dir
    CLOBBER.include @pkg_dir

    if @ns and !@ns.empty?
      namespace(@ns) { define_tasks }
    else
      define_tasks
    end

    #
    # tasks to be kept out of @ns namespace
    #

    desc "config check"
    task buildar: :valid_gemspec do
      spacer = " " * 14
      gemspec = self.gemspec
      puts
      puts "     Project: #{gemspec.name} #{gemspec.version}"
      puts "Gemspec file: #{@gemspec_file}" if @gemspec_file
      puts <<EOF
Version file: #{@version_file}
     Use git: #{@use_git}
 Package dir: #{@pkg_dir}
       Files: #{gemspec.files.join("\n#{spacer}")}
  Built gems: #{Dir[@pkg_dir +  '/*.gem'].join("\n#{spacer}")}
# using Buildar #{Buildar.version}
EOF
      puts
    end

    if @version_file
      namespace :bump do
        # tasks :bump_major, :bump_minor, :bump_patch, :bump_build
        # commit the version file if @use_git
        #
        [:major, :minor, :patch, :build].each { |v|
          desc "increment the #{v} number in #{@version_file}"
          task v do
            old_version = self.read_version
            new_version = self.class.bump(v, old_version)

            puts "bumping #{old_version} to #{new_version}"
            self.write_version new_version

            if @use_git and v != :build
              msg = "Buildar version:bump_#{v} to #{new_version}"
              sh "git commit #{@version_file} -m #{msg.inspect}"
            end
          end
        }
      end
    end
  end

  def define_tasks
    desc "invoke :test and :bump_build conditionally"
    task pre_build: @pkg_dir do
      Rake::Task[:test].invoke if Rake::Task.task_defined? :test
      Rake::Task['bump:build'].invoke if @version_file
    end

    # can't make this a file task, because the version could be bumped
    # as a dependency, changing the target file
    #
    desc "build a .gem in #{@pkg_dir}/ using `gem build`"
    task build: :pre_build do
      if @gemspec_file
        sh "gem build #{@gemspec_file}"
        mv File.basename(self.gem_file), self.gem_file
      else
        Rake::Task[:gem_package].invoke
      end
    end

    # roughly equivalent to `gem build self.gemspec`
    # operates with a hard or soft gemspec
    #
    desc "build a .gem in #{@pkg_dir}/ using Gem::PackageTask"
    task gem_package: :pre_build do
      # definine the task at runtime, rather than requiretime
      # so that the gemspec will reflect any version bumping since requiretime
      require 'rubygems/package_task'
      Gem::PackageTask.new(self.gemspec).define
      Rake::Task["package"].invoke
    end

    # desc "used internally; make sure we have .gem for the current version"
    task :built do
      Rake::Task[:build].invoke unless File.exists? self.gem_file
    end

    desc "publish the current version to rubygems.org"
    task publish: :built do
      sh "gem push #{self.gem_file}"
    end

    desc "build, publish" << (@use_git ? ", tag " : '')
    task release: [:build, :publish] do
      Rake::Task[:tag].invoke if @use_git
    end

    desc "install the current version"
    task install: :built do
      sh "gem install #{self.gem_file}"
    end

    desc "build a new version and install"
    task install_new: [:build, :install]

    desc "display current version"
    task version: :valid_gemspec do
      puts self.gemspec.version
    end

    task :valid_gemspec do
      unless self.gemspec
        msg = "gemspec required"
        msg += "; checked #{self.gemspec_file}" if self.gemspec_file
        raise msg
      end
    end

    #
    # Optional tasks
    #

    if @version_file
      namespace :release do
        [:major, :minor, :patch].each { |v|
          desc "increment the #{v} number and release"
          task v => ["bump:#{v}", :release]
        }
      end
    end

    if @use_git
      desc "annotated git tag with version and message"
      task tag: :message do
        Rake::Task[:test].invoke if Rake::Task.task_defined? :test
        tagname = "v#{self.gemspec.version}"
        message = ENV['message'] || "auto-tagged #{tagname} by Buildar"
        sh "git tag -a #{tagname.inspect} -m #{message.inspect}"
        sh "git push origin --tags"
      end

      # right now only :tag depends on this, but maybe others in the future?
      # desc "used internally; make sure ENV['message'] is populated"
      task :message do
        if !ENV['message'] or ENV['message'].empty?
          print "This task requires a message:\n> "
          ENV['message'] = $stdin.gets.chomp
        end
      end
    end
  end
end
