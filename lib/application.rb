begin
  require 'hotcocoa'
rescue LoadError
  require 'rubygems'
  require 'hotcocoa'
end

framework 'Cocoa'
framework 'Sparkle'

# adding the lib/ folder to the load path
$: << File.dirname(__FILE__)

require 'core_extensions'
require 'documents/project'

class LightingSetup
  include HotCocoa

  def start
    application do |app|
      app.delegate = self
      app.did_finish_launching { SUUpdater.sharedUpdater.checkForUpdatesInBackground }
    end
  end
end

LightingSetup.new.start
