begin
  require 'hotcocoa'
rescue LoadError
  require 'rubygems'
  require 'hotcocoa'
end

framework 'Cocoa'

require 'lib/core_extensions'
require 'lib/documents/project'

class LightingSetup
  include HotCocoa

  def start
    application do |app|
      app.delegate = self
      app.should_terminate_after_last_window_closed? { true }
    end
  end  
end

LightingSetup.new.start
