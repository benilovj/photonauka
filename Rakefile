require 'rubygems'
require 'hotcocoa/rake_tasks'

require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new

desc "Get signature for app"
task :sign => :dmg do
  dmg = FileList['*.dmg'].first
  signature = `sparkle_feed/sign_update.rb #{dmg} sparkle_feed/dsa_priv.pem`
  puts "DSA signature for #{dmg}: #{signature}"
end

task :dmg => :spec

task :default => :run
