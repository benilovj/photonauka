require 'rubygems'
require 'hotcocoa/application/builder'

builder = Application::Builder.new 'LightingPlanner.appspec'

desc 'Build the application'
task :build do
  builder.build
end

desc 'Build a deployable version of the application'
task :deploy do
  builder.build deploy: true
end

desc 'Build and execute the application'
task :run => [:build] do
  builder.run
end

desc 'Cleanup build files'
task :clean do
  builder.remove_bundle_root
end

desc 'Create the dmg archive'
task :dmg => :deploy do
  rm_rf 'LightingPlanner.dmg'
  sh "hdiutil create -srcfolder LightingPlanner.app $TMPDIR/LightingPlanner.tmp.dmg"
  sh "hdiutil convert $TMPDIR/LightingPlanner.tmp.dmg -format UDZO -imagekey zlib-level=9 -o LightingPlanner.dmg"
  rm_rf File.join(ENV['TMPDIR'], 'LightingPlanner.tmp.dmg')
end

task :default => [:clean, :run]
