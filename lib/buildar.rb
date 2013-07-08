# Buildar is effectively a hand-rolled singleton.  Yes, a NIH miserable excuse
# for a global.
# Look, we want to be able to call Buildar.conf in the project rakefile, but
# we need that data accessible here and inside lib/buildar/tasks.
# So we need a "global".
# But if we use a class-based singleton, it's namespaced.
# And it can't be set to nil, for example.
#
class Buildar
  def self.dir(file)
    File.expand_path('..', file)
  end

  def self.version
    File.read(File.join(dir(__FILE__), 'VERSION')).chomp
  end

  # Call this from the rakefile, like:
  #   Buildar.conf(__FILE__) do |b|
  #     b.name = 'foo'
  #     # ...
  #   end
  #
  def self.conf(rakefile = nil)
    unless defined?(@@instance)
      args = rakefile ? [File.dirname(rakefile)] : []
      @@instance = Buildar.new(*args)
    end
    yield @@instance if block_given?
  end

  # Confirming singleton.
  # Only buildar/raketasks should need to call this
  # Use conf inside project/Rakefile
  #
  def self.instance
    raise "no instance; call Buildar.conf" unless defined?(@@instance)
    @@instance
  end

  # e.g. bump(:minor, '1.2.3') #=> '1.3.0'
  # only works for versions consisting of integers delimited by periods (dots)
  #
  def self.bump(position, version)
    pos = [:major, :minor, :patch, :build].index(position) || position
    places = version.split('.')
    if pos >= places.length and pos <= places.length + 2
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

  attr_accessor :root, :name,
                :use_git, :publish,
                :use_gemspec_file, :gemspec_filename,
                :use_version_file, :version_filename,
                :use_manifest_file, :manifest_filename

  attr_writer :gemspec_filename

  def initialize(root = nil)
    @root = root ? File.expand_path(root) : Dir.pwd
    @name = File.split(@root).last
    @use_git = false
    @publish = { rubygems: false }
    @use_gemspec_file = true
    @use_version_file = false
    @version_filename = 'VERSION'
    @use_manifest_file = false
    @manifest_filename = 'MANIFEST.txt'
  end

  def gemspec
    @use_gemspec_file ? self.hard_gemspec : self.soft_gemspec
  end

  def soft_gemspec
    @soft_gemspec ||= Gem::Specification.new
    @soft_gemspec.name = @name
    @soft_gemspec.version = self.version if @use_version_file
    @soft_gemspec.files = self.manifest if @use_manifest_file
    @soft_gemspec
  end

  # load every time; cache locally if you must
  #
  def hard_gemspec
    Gem::Specification.load self.gemspec_file
  end

  def gemspec_file
    File.join(@root, self.gemspec_filename)
  end

  # @name.gemspec is the default, but don't set this in the constructor
  # it's common to set the name after intialization.  e.g. via Buildar.conf
  # so set the default on first invocation.  After that, it's an accessor.
  #
  def gemspec_filename
    @gemspec_filename ||= "#{@name}.gemspec"
    @gemspec_filename
  end

  def version
    File.read(self.version_file).chomp
  end

  def write_version new_version
    File.open(self.version_file, 'w') { |f| f.write(new_version) }
  end

  def version_file
    File.join(@root, @version_filename)
  end

  def available_version
    return self.version if @use_version_file
    version = self.gemspec.version
    raise "gemspec.version is missing" if !version or version.to_s.empty?
    version
  end

  # where we expect a built gem to land
  #
  def gemfile
    path = File.join(@root, 'pkg', "#{@name}-#{self.available_version}.gem")
    raise "gemfile #{path} does not exist" unless File.exists?(path)
    path
  end

  def available_manifest
    return self.manifest if @use_manifest_file
    manifest = self.gemspec.files
    raise "gemspec.files is missing" if !manifest or manifest.to_s.empty?
    manifest
  end

  def manifest
    File.readlines(self.manifest_file).map { |line| line.chomp }
  end

  def manifest_file
    File.join(@root, @manifest_filename)
  end
end
