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
  include HotCocoa::Mappings

  IMAGE_INSET = 5
  
  GRIP_RADIUS = 3
  BORDER_INSET = IMAGE_INSET
  
  def initWithFrame(frame)
    super
    unless self.nil?
      define_tracking_areas
    end
    self
  end
  
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
  
  def filename=(filename)
    @image = NSImage.alloc.initWithContentsOfFile filename
  end
  
  def drawRect(rect)
    draw_image
    draw_rotation_grips
  end
  
  protected
  def define_tracking_areas
    squares = border_corners.map {|point| square_around(point, radius: GRIP_RADIUS)}
    for square in squares
      self.addTrackingArea(HotCocoa.tracking_area(rect: square,
                                               options: [:mouse_entered_and_exited, :active_in_key_window],
                                                 owner: self ))
    end
  end
  
  def draw_image
    @image.drawInRect(bounds_with_inset(IMAGE_INSET),
            fromRect: NSZeroRect,
           operation: NSCompositeSourceOver,
            fraction: 1.0)
  end
  
  def draw_rotation_grips
    border_corners.each {|corner| draw_grip_at(corner) }
  end

  def border_corners
    bounds_with_inset(BORDER_INSET).corner_points
  end

  def draw_grip_at(point)
    HotCocoa.color(name:"black").setStroke
    HotCocoa.color(name:"lightGray").setFill
    circlePath = NSBezierPath.bezierPath
    circlePath.appendBezierPathWithArcWithCenter(point, radius: GRIP_RADIUS, startAngle: 0, endAngle:360)
    circlePath.stroke
    circlePath.fill
  end
  
  def square_around(point, radius: radius)
    CGRectMake(point.x - radius, point.y - radius, 2 * radius, 2 * radius)
  end
  
  def bounds_with_inset(inset)
    NSMakeRect(inset, inset, bounds.size.width - 2*inset, bounds.size.height - 2*inset)
  end
  
  def update_cursor
    cursor = case
    when (@in_area and @mousedown) then rotate_cursor
    when (@in_area and not @mousedown) then NSCursor.openHandCursor
    else NSCursor.arrowCursor
    end
    cursor.set
  end
  
  def rotate_cursor
    @rotate_cursor ||= load_rotate_cursor
  end
  
  def load_rotate_cursor
    image_name = NSBundle.mainBundle.pathForResource 'rotate_cursor', ofType:'png'
    image = NSImage.alloc.initWithContentsOfFile(image_name)
    NSCursor.alloc.initWithImage(image, hotSpot:NSMakePoint(7,7))
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
          win << rotatable_image_view(frame: [50,50,100,100], 
                             image_filename: png_filename('zoom_2x2_128_031')) do |image_view|
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
