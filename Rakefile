require 'rubygems'
require 'hotcocoa/rake_tasks'

require 'rspec/core/rake_task'

require 'date'

desc "Run specs"
RSpec::Core::RakeTask.new

def path_to_source_dmg
  @path_to_source_dmg ||= FileList['*.dmg'].first
end

def target_dmg_name
  path_to_source_dmg.pathmap("%n") + "-" + version_string + '.dmg'
end

def version_string
  Date.today.strftime("%Y%m%d")
end

def dropbox_public_path
  File.join(ENV["HOME"], "Dropbox", "Public")
end

def path_to_version_file
  File.join("lib", "photonauka", "version.rb")
end

def github_credentials
  @credentials ||= File.read(File.join(ENV['HOME'], ".github")).strip
end

def secured(url)
  "https://#{github_credentials}@api.github.com" + url
end

def get(url)
  JSON.parse(RestClient.get(secured(url)))
end

desc "Get signature for app"
task :sign => :dmg do
  @signature = `sparkle_feed/sign_update.rb #{path_to_source_dmg} sparkle_feed/dsa_priv.pem`
  puts "DSA signature for #{path_to_source_dmg}: #{@signature}"
end

task :release_notes do
  require 'rest-client'
  require 'json'
  require 'stringio'
  require 'haml'

  milestones = get('/repos/benilovj/photonauka/milestones?state=closed')
  expected_milestone_name = Date.today.strftime("%Y-%m-%d")
  milestone = milestones.detect {|m| m["title"] == expected_milestone_name}
  raise "Did not find milestone #{expected_milestone_name}!" if milestone.nil?

  issues = get("/repos/benilovj/photonauka/issues?milestone=#{milestone["number"]}&state=closed&sort=created&direction=desc")
  template = File.read('sparkle_feed/release_notes.haml')

  @release_notes = Haml::Engine.new(template).render(Object.new, :issues => issues)
  puts "Release notes: \n" + @release_notes
end

task :bump_version do
  load path_to_version_file
  new_version = (Photonauka::VERSION.split(".")[0..1] + [version_string]).join(".")
  File.open(path_to_version_file, "w") do |f|
    f.puts "module Photonauka"
    f.puts "  VERSION = '#{new_version}'"
    f.puts "end"
  end
end

task :upload_dmg => :dmg do
  cp path_to_source_dmg, File.join(dropbox_public_path, target_dmg_name)
end

task :generate_sparkle_feed => [:sign, :release_notes] do
  require 'haml'
  
  template = File.read('sparkle_feed/feed.haml')
  load path_to_version_file
  
  File.open(File.join(dropbox_public_path, "feed.xml"), "w") do |f|
    f << Haml::Engine.new(template).render(Object.new,
      :release_notes => @release_notes,
      :release_dmg   => target_dmg_name,
      :dmg_signature => @signature,
      :version       => Photonauka::VERSION,
      :release_name  => Date.today.strftime("%Y-%m-%d")
    )
  end
end

task :release => [:bump_version, :upload_dmg, :generate_sparkle_feed]

task :dmg => :spec

task :default => :run
