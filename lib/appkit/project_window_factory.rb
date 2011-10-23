require 'lib/hotcocoa/mappings/appkit/floor_plan_view'

class ProjectWindowFactory
  include HotCocoa
  
  def initialize
    @window_cascade_point = NSPoint.new(1,1)
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
    window(frame: [@window_cascade_point.x, @window_cascade_point.y, 500, 500], view: :nolayout) do |win|
      @window_cascade_point = win.cascadeTopLeftFromPoint(@window_cascade_point)
      win.view = floor_plan_view(auto_resize: [:width, :height]) do |view|
        view.setWantsLayer(true)
      end
      win.view << slider(:min => 0, :max => 360, :tic_marks => 25) do |s|
        s.frameSize = [320, 30]
        s.setAllowsTickMarkValuesOnly(true)
        s.on_action do |s|
          win.view.rotation = s.to_i
          win.view.needsDisplay = true
        end
      end
    end
  end
end