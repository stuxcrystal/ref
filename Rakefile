#!/usr/bin/env rake

$:.push File.join(File.dirname(__FILE__), 'lib')

require 'ref'

begin
  require 'rspec'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--color --backtrace --format documentation'
  end

  task :default => :spec
rescue LoadError
  puts 'Error loading Rspec rake tasks, probably building the gem...'
end

spec = eval(File.read(File.expand_path('../ref.gemspec', __FILE__)))

GEM_NAME       = 'ref'
EXTENSION_NAME = 'extension'
JAVA_EXT_NAME  = 'ref_ext'
CORE_GEMSPEC   = Gem::Specification.load('ref.gemspec')

if Ref.jruby?
  CORE_GEM = "#{GEM_NAME}-#{Ref::VERSION}-java.gem"

  require 'rake/javaextensiontask'
  Rake::JavaExtensionTask.new(JAVA_EXT_NAME, CORE_GEMSPEC) do |ext|
    ext.ext_dir = 'ext'
  end
else
  CORE_GEM = "#{GEM_NAME}-#{Ref::VERSION}.gem"
end

task :clean do
  rm_f Dir.glob('./**/*.so')
  rm_f Dir.glob('./**/*.bundle')
  rm_f Dir.glob('./lib/*.jar')
  mkdir_p 'pkg'
end

namespace :build do
  build_deps = [:clean]
  build_deps << :compile if Ref.jruby?
  desc "Build #{CORE_GEM} into the pkg directory"
  task :core => build_deps do
    sh "gem build #{CORE_GEMSPEC.name}.gemspec"
    sh 'mv *.gem pkg/'
  end
end

task :build => ['build:core']

namespace :test do
  namespace :performance do
    desc "Run a speed test on how long it takes to create 100000 weak references"
    task :weak_reference do
      puts "Testing performance of weak references..."
      unless Ref.jruby?
        t = Time.now
        Process.fork do
          100000.times do
            Ref::WeakReference.new(Object.new)
          end
        end
        Process.wait
        puts "Creating 100,000 weak references took #{Time.now - t} seconds"
      else
        puts 'Cannot run weak_reference performance test on JRuby - Fork is not available on this platform.'
      end
    end

    desc "Run a speed test on how long it takes to create 100000 soft references"
    task :soft_reference do
      puts "Testing performance of soft references..."
      t = Time.now
      100000.times do
        Ref::SoftReference.new(Object.new)
      end
      GC.start
      GC.start
      puts "Creating 100,000 soft references took #{Time.now - t} seconds"
    end
  end
end
