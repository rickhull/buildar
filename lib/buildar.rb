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

  def initialize(root = nil, name = nil)
    @root = root ? File.expand_path(root) : Dir.pwd
    @name = name || File.split(@root).last
    @use_git = false
    @publish = { rubygems: false }
    @use_gemspec_file = true
    self.gemspec_filename
    @use_version_file = false
    @version_filename = 'VERSION'
    @use_manifest_file = false
    @manifest_filename = 'MANIFEST.txt'
  end

  def gemspec_filename
    @gemspec_filename ||= "#{@name}.gemspec"
    @gemspec_filename
  end

  def gemspec_file
    @gemspec_file = File.join(@root, self.gemspec_filename)
  end

  def gemspec
    @gemspec ||= self.hard_gemspec
  end

  def hard_gemspec
    #eval(File.read(self.gemspec_file))
    @hard_gemspec = Gem::Specification.load self.gemspec_file
  end

  def soft_gemspec
    @soft_gemspec ||= Gem::Specification.new
    @soft_gemspec.name = @name
    @soft_gemspec.version = self.version if @use_version_file
    @soft_gemspec.files = self.manifest if @use_manifest_file
    @soft_gemspec
  end

  def gemfile
    path = File.join(@root, 'pkg', "#{@name}-#{self.available_version}.gem")
    raise "gemfile #{path} does not exist" unless File.exists?(path)
    path
  end

  def available_version
    if @use_version_file
      self.version
    #elsif !@gemspec.version
    #  raise "gemspec.version is false or nil"
    #elsif @gemspec.version.to_s.empty?
    #  raise "gemspec.version is empty"
    else
      self.gemspec.version
    end
  end

  def available_manifest
    if @use_manifest_file
      self.manifest
#    elsif !@gemspec.files
#      raise "gemspec.files is false or nil"
#    elsif @gemspec.files.empty?
#      raise "gemspec.files is empty"
    else
      self.gemspec.files
    end
  end

  def version_file
    File.join(@root, @version_filename)
  end

  def version
    File.read(self.version_file).chomp
  end

  def write_version new_version
    File.open(self.version_file, 'w') { |f| f.write(new_version) }
  end

  def manifest_file
    File.join(@root, @manifest_filename)
  end

  def manifest
    File.readlines(self.manifest_file).map { |line| line.chomp }
  end
end
