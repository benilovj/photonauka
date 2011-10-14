require 'lib/hotcocoa/mappings/appkit/floor_plan_view'

class ProjectWindowFactory
  include HotCocoa
  
  def initialize
    @window_cascade_point = NSPoint.new(0,0)
  end
  
  class << self
    # yuck.
    # it'd be nice if this weren't a singleton, but I don't see any other way of preserving the cascading behaviour
    # and injecting this factory into the NSDocument subclass
    def instance
      @instance ||= ProjectWindowFactory.new
    end
  end
  
  def make_new_window
    window do |win|
      win.view = floor_plan_view(frame: [@window_cascade_point.x, @window_cascade_point.y, 500, 500], auto_resize: [:width, :height]) do |view|
        view.setWantsLayer(true)
      end
      @window_cascade_point = win.cascadeTopLeftFromPoint(@window_cascade_point)
    end
  end
end