require 'rubygems' # disable this for a deployed application
require 'hotcocoa'

class CGRect
  def corner_points
    [[origin.x, origin.y], 
     [origin.x + size.width, origin.y],
     [origin.x + size.width, origin.y + size.height],
     [origin.x, origin.y + size.height]
     ].map {|x,y| NSMakePoint(x,y)}
  end
  
  def with_inset(inset)
    NSMakeRect(origin.x + inset, origin.y + inset, size.width - 2*inset, size.height - 2*inset)
  end
  
  class << self
    def square_with_center(center, side_length: length)
      NSMakeRect(center.x - length / 2, center.y - length / 2, length, length)
    end
  end
end

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
    tracking_area.initWithRect rect,
                      options: options.delete(:options),
                        owner: options.delete(:owner),
                     userInfo: nil
  end
end

class RotatableImageView < NSView
  IMAGE_INSET = 5
  
  GRIP_RADIUS = 3
  BORDER_INSET = IMAGE_INSET
  
  attr_writer :delegate
  
  def initWithFrame(frame)
    super
    define_tracking_areas unless self.nil?
    self
  end
  
  def mouseEntered(event)
    @cursor_over_grip = true
    fire_events_if_needed
  end

  def mouseExited(event)
    @cursor_over_grip = false
    fire_events_if_needed
  end
  
  def mouseDown(event)
    @mouse_pressed = true
    fire_events_if_needed
  end
  
  def mouseUp(event)
    @mouse_pressed = false
    fire_events_if_needed
  end
  
  def filename=(filename)
    @image = NSImage.alloc.initWithContentsOfFile filename
  end
  
  def drawRect(rect)
    draw_image
    draw_rotation_grips
  end
  
  protected
  def define_tracking_areas
    squares = border_corners.map {|point| CGRect.square_with_center(point, side_length: 2*GRIP_RADIUS)}
    for square in squares
      self.addTrackingArea(HotCocoa.tracking_area(rect: square,
                                               options: [:mouse_entered_and_exited, :active_in_key_window],
                                                 owner: self ))
    end
  end
  
  def draw_image
    @image.drawInRect(bounds.with_inset(IMAGE_INSET),
            fromRect: NSZeroRect,
           operation: NSCompositeSourceOver,
            fraction: 1.0)
  end
  
  def draw_rotation_grips
    border_corners.each {|corner| draw_grip_at(corner) }
  end

  def border_corners
    bounds.with_inset(BORDER_INSET).corner_points
  end

  def draw_grip_at(point)
    HotCocoa.color(name:"black").setStroke
    HotCocoa.color(name:"lightGray").setFill
    circlePath = NSBezierPath.bezierPath
    circlePath.appendBezierPathWithArcWithCenter(point, radius: GRIP_RADIUS, startAngle: 0, endAngle:360)
    circlePath.stroke
    circlePath.fill
  end
  
  def fire_events_if_needed
    unless @delegate.nil?
      case
      when (@cursor_over_grip and @mouse_pressed) then @delegate.rotation_started
      when (@cursor_over_grip and not @mouse_pressed) then @delegate.mouse_over_grip
      else @delegate.rotation_finished
      end
    end
  end
end

class RotatableImageController
  def rotation_started
    rotate_cursor.set
  end
  
  def rotation_finished
    NSCursor.arrowCursor.set
  end
  
  def mouse_over_grip
    NSCursor.openHandCursor.set
  end
  
  protected
  def rotate_cursor
    @rotate_cursor ||= load_rotate_cursor
  end
  
  def load_rotate_cursor
    image_name = NSBundle.mainBundle.pathForResource 'rotate_cursor', ofType:'png'
    image = NSImage.alloc.initWithContentsOfFile(image_name)
    NSCursor.alloc.initWithImage(image, hotSpot:[7,7])
  end
end

HotCocoa::Mappings.map rotatable_image_view: RotatableImageView do
  defaults frame: CGRectZero

  def init_with_options image_view, options
    view = image_view.initWithFrame options.delete :frame
    view.filename = options.delete(:image_filename)
    view
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
          rotatable_image_controller = RotatableImageController.new
          win << rotatable_image_view(frame: [50,50,100,100], 
                             image_filename: png_filename('zoom_2x2_128_031')) do |image_view|
            image_view.setFrameCenterRotation(image_view.frameCenterRotation + 45)
            image_view.delegate = rotatable_image_controller
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
