require 'bundler/gem_tasks'
require 'appraisal'
require 'rake/testtask'
require 'cucumber/rake/task'

desc 'Default: clean, all.'
task :default => [:clean, :all]

desc 'Test the activerecord-tableless on all supported Rails versions.'
task :all do |t|
  if ENV['BUNDLE_GEMFILE']
    exec('rake test cucumber')
  else
    Rake::Task["appraisal:install"].execute
    exec('rake appraisal test cucumber')
  end
end

desc 'Test the activerecord-tableless plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'profile'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Run integration test'
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--format progress}
end

desc 'Clean up files.'
task :clean do |t|
  FileUtils.rm_rf "doc"
  FileUtils.rm_rf "tmp"
  FileUtils.rm_rf "pkg"
  FileUtils.rm_rf "public"
  Dir.glob("activerecord-tableless-*.gem").each{|f| FileUtils.rm f }
end
