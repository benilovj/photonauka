require 'rubygems' # disable this for a deployed application
require 'hotcocoa'

HotCocoa::Mappings.map tracking_area: NSTrackingArea do
  defaults rect: CGRectZero

  constant :options, {
    mouse_entered_and_exited: NSTrackingMouseEnteredAndExited,
    mouse_moved:              NSTrackingMouseMoved,
    cursor_update:            NSTrackingCursorUpdate,
    active_in_key_window:     NSTrackingActiveInKeyWindow,
    active_first_responder:   NSTrackingActiveWhenFirstResponder,
    active_in_active_app:     NSTrackingActiveInActiveApp,
    active_always:            NSTrackingActiveAlways,
    assume_inside:            NSTrackingAssumeInside,
    in_visible_rectangle:     NSTrackingInVisibleRect,
    enabled_during_drag:      NSTrackingEnabledDuringMouseDrag
  }
  
  def init_with_options tracking_area, options
    rect = options.delete(:rect)
    rect = CGRectMake(*rect) if rect.is_a?(Array)
    tracking_area.initWithRect rect,
                      options: options.delete(:options),
                        owner: options.delete(:owner),
                     userInfo: nil
  end
end

HotCocoa::Mappings.map rotatable_image_view: NSImageView do
  defaults frame: CGRectZero

  def init_with_options image_view, options
    image_view.initWithFrame options.delete :frame
  end
  
  custom_methods do
    def mouseEntered(event)
      @in_area = true
      update_cursor
    end

    def mouseExited(event)
      @in_area = false
      update_cursor
    end
    
    def mouseDown(event)
      @mousedown = true
      update_cursor
    end
    
    def mouseUp(event)
      @mousedown = false
      update_cursor
    end
    
    def update_cursor
      cursor = case
      when (@in_area and @mousedown) then NSCursor.closedHandCursor
      when (@in_area and not @mousedown) then NSCursor.openHandCursor
      else NSCursor.arrowCursor
      end
      cursor.set
    end
  end
end

class LightingPlanner
  include HotCocoa

  def start
    application name: 'LightingPlanner' do |app|
      app.delegate = self
      window frame: [100, 100, 500, 500], title: 'Lighting Planner' do |win|
        win << view(frame: [0,0,200,200]) do |view|
          view.setWantsLayer(true)
          view << rotatable_image_view(frame: [50,50,100,100]) do |image_view|
            image_view.file = NSBundle.mainBundle.pathForResource 'zoom_2x2_128_031', ofType:'png'
            image_view.addTrackingArea(tracking_area(rect: [0, 0, 10, 10],
                                                  options: [:mouse_entered_and_exited, :active_in_key_window],
                                                    owner: image_view ))
            image_view.setFrameCenterRotation(image_view.frameCenterRotation + 45)
          end
        end

        win.will_close { exit }
      end
    end
  end

  # file/open
  def on_open(menu)
  end

  # file/new
  def on_new(menu)
  end

  # help menu item
  def on_help(menu)
  end

  # This is commented out, so the minimize menu item is disabled
  #def on_minimize(menu)
  #end

  # window/zoom
  def on_zoom(menu)
  end

  # window/bring_all_to_front
  def on_bring_all_to_front(menu)
  end
end

LightingPlanner.new.start
