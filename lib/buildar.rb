# Buildar is effectively a hand-rolled singleton.  Yes, a NIH miserable excuse
# for a global.
# Look, we want to be able to call Buildar.conf in the project rakefile, but
# we need that data accessible here and inside lib/buildar/raketasks.
# So we need a global.  But if we use a class-based singleton, it's namespaced.
# And it can't be set to nil, for example.
#
class Buildar
  attr_accessor :root, :version_filename, :manifest_filename,
                :use_git, :publish
  attr_reader :name

  # Call this from the rakefile, like:
  # Buildar.conf(__FILE__) do |b|
  #   b.name = 'foo'
  #   # ...
  # end
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

  def initialize(root = nil, name = nil)
    @root = root ? File.expand_path(root) : Dir.pwd
    @name = name || File.split(@root).last
    @version_filename = 'VERSION'
    @manifest_filename = 'MANIFEST.txt'
    @use_git = true
    @publish = { rubygems: true }
  end

  # previously, we did this in initialize
  # now, give conf a chance to fix things up before calling self.version etc.
  #
  def gemspec
    @gemspec ||= Gem::Specification.new do |s|
      # Static assignments
      s.name        = @name
      s.summary     = "FIX"
      s.description = "FIX"
      s.authors     = ["FIX"]
      s.email       = "FIX@FIX.COM"
      s.homepage    = "http://FIX.COM/"
      s.licenses    = ['FIX']
      # s.has_rdoc    = true
      # s.test_files  = ['FIX']

      # Dynamic assignments
      s.files       = self.manifest
      s.version     = self.version
      # s.date        = Time.now.strftime("%Y-%m-%d")

      # s.add_runtime_dependency  "rest-client", ["~> 1"]
      # s.add_runtime_dependency         "json", ["~> 1"]
      s.add_development_dependency "minitest", [">= 0"]
      s.add_development_dependency     "rake", [">= 0"]
      s.add_development_dependency  "buildar", ["> 0.4"]
    end
  end

  # Update gemspec as well if it's already been created
  #
  def name=(name)
    @name = name
    @gemspec.name = name if @gemspec
  end

  def version_file
    File.join(@root, @version_filename)
  end

  def manifest_file
    File.join(@root, @manifest_filename)
  end

  def version
    File.read(self.version_file).chomp
  end

  def manifest
    File.readlines(self.manifest_file).map { |line| line.chomp }
  end

  def write_version new_version
    File.open(self.version_file, 'w') { |f| f.write(new_version) }
  end
end
