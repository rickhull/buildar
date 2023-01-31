require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

task default: :test

begin
  require 'buildar'

  Buildar.new do |b|
    b.gemspec_file = 'buildar.gemspec'
    b.version_file = 'VERSION'
    b.use_git      = true
  end

rescue LoadError => e
  warn "buildar failed to load: #{e}"
end
