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

class RotatableImageView < NSView
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
  
  def file=(file)
    @image = NSImage.alloc.initWithContentsOfFile file
  end
  
  def drawRect(rect)
    @image.drawInRect(bounds, fromRect:NSZeroRect, operation:NSCompositeSourceOver, fraction:1.0)
    NSColor.blackColor.setStroke
    NSColor.lightGrayColor.setFill
    circlePath = NSBezierPath.bezierPath
    point_coordinates = [[2,2],
                         [bounds.size.width - 10, 2],
                         [bounds.size.width - 10, bounds.size.height - 10],
                         [2, bounds.size.height - 10]]
    point_coordinates.each do |x, y|
      circlePath.appendBezierPathWithOvalInRect(CGRectMake(x, y, 8, 8))
      circlePath.stroke
      circlePath.fill
    end
  end
  
  protected
  def update_cursor
    cursor = case
    when (@in_area and @mousedown) then NSCursor.closedHandCursor
    when (@in_area and not @mousedown) then NSCursor.openHandCursor
    else NSCursor.arrowCursor
    end
    cursor.set
  end
end

HotCocoa::Mappings.map rotatable_image_view: RotatableImageView do
  defaults frame: CGRectZero

  def init_with_options image_view, options
    image_view.initWithFrame options.delete :frame
  end
end

class LightingPlanner
  include HotCocoa

  def start
    application name: 'Lighting Planner' do |app|
      app.delegate = self
      window frame: [100, 100, 500, 500], title: 'Lighting Planner' do |win|
        win.setBackgroundColor(NSColor.colorWithPatternImage(png_file('grid')))
        win << view(frame: [0,0,200,200]) do |view|
          view.setWantsLayer(true)
          win << rotatable_image_view(frame: [50,50,100,100]) do |image_view|
            image_view.file = png_filename('zoom_2x2_128_031')
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
  
  protected
  def png_file(filename)
    NSImage.alloc.initWithContentsOfFile(png_filename(filename))
  end
  
  def png_filename(filename)
    NSBundle.mainBundle.pathForResource filename, ofType:'png'
  end
end

LightingPlanner.new.start
