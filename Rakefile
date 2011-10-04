require 'rubygems'
require 'hotcocoa/application/builder'

builder = Application::Builder.new 'LightingSetup.appspec'

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

desc 'Create the dmg archive from the application bundle'
task :dmg => :deploy do
  app_name = builder.spec.name
  rm_rf "#{app_name}.dmg"
  sh "hdiutil create #{app_name}.dmg -quiet -srcdir #{app_name}.app -format UDZO -imagekey zlib-level=9"
end

task :default => :run
