begin
 require 'hotcocoa'
rescue LoadError
  require 'rubygems'
  require 'hotcocoa'
end

require 'lib/document'

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

module PngImages
  def png_file(filename)
    NSImage.alloc.initWithContentsOfFile(png_filename(filename))
  end
  
  def png_filename(filename)
    NSBundle.mainBundle.pathForResource filename, ofType:'png'
  end
end

class RotationEventResponder
  attr_writer :delegate
  
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
  
  protected
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

class RotatableImageView < NSView
  IMAGE_INSET = 5
  
  GRIP_RADIUS = 3
  BORDER_INSET = IMAGE_INSET
  
  attr_writer :delegate
  
  def initWithFrame(frame)
    super
    unless self.nil?
      self.selected = false
      @rotation_handler = RotationEventResponder.new
    end
    self
  end
  
  def delegate=(delegate)
    @delegate = delegate
    @rotation_handler.delegate = delegate
  end
  
  def mouseDown(event)
    @initialLocation = event.locationInWindow
    @initialLocation.x -= frame.origin.x
    @initialLocation.y -= frame.origin.y
    
    self.selected = true
  end
  
  def mouseDragged(event)
    current_location = event.locationInWindow
    new_origin = [current_location.x - @initialLocation.x, current_location.y - @initialLocation.y]
    self.setFrameOrigin(new_origin)
  end
  
  def filename=(filename)
    @image = NSImage.alloc.initWithContentsOfFile filename
  end
  
  def drawRect(rect)
    draw_image
    draw_rotation_grips if @selected
  end
  
  def selected=(should_be_selected)
    if @selected and not should_be_selected
      self.trackingAreas.each {|area| removeTrackingArea(area)}
    elsif not @selected and should_be_selected
      define_tracking_areas(@rotation_handler)
    end
    @selected = should_be_selected
    setNeedsDisplay(true)
  end
  
  def deselect
    self.selected = false
  end
  
  protected
  def define_tracking_areas(rotation_handler)
    squares = border_corners.map {|point| CGRect.square_with_center(point, side_length: 2*GRIP_RADIUS)}
    for square in squares
      self.addTrackingArea(HotCocoa.tracking_area(rect: square,
                                               options: [:mouse_entered_and_exited, :active_in_key_window],
                                                 owner: rotation_handler ))
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
end

class FloorPlanView < NSView
  include PngImages
  
  attr_writer :floor_plan
  
  def mouseDown(event)
    deselect_rotatable_images
  end
  
  def drawRect(rect)
    NSColor.colorWithPatternImage(png_file('grid')).setFill
    NSRectFill(bounds)
  end
  
  protected
  def deselect_rotatable_images
    subviews.select {|view| view.is_a?(RotatableImageView)}.map(&:deselect)
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

HotCocoa::Mappings.map floorplan_view: FloorPlanView do
  defaults frame: CGRectZero

  def init_with_options view, options
    view.initWithFrame options.delete :frame
  end
end

class LightingPlanner
  include HotCocoa
  include PngImages

  def initialize
    @document = MyDocument.new
  end

  def start
    application name: 'Lighting Planner' do |app|
      app.delegate = self
      @window = window frame: [100, 100, 500, 500], title: 'Lighting Planner' do |win|
        win.view = floor_plan_view
        win.will_close { exit }
      end
      
      @document.view = @window.view
      @window.setWindowController(NSWindowController.new)
      @window.windowController.setDocument(@document)
    end
  end
  
  def on_save_as(menu)    
    @document.saveDocumentAs(self)
  end
  
  # TODO: is this the right way of printing?
  def on_print(menu)
    print_operation = @document.printOperationWithSettings({}, error:nil)
    
    print_operation.runOperationModalForWindow(application.mainWindow,
                    delegate:self,
                    didRunSelector: "printed:",
                    contextInfo: nil)
  end
  
  def printed(sender)
  end
  
  protected
  def floor_plan_view
    floorplan_view(frame: [0,0,400,400], auto_resize: [:width, :height]) do |view|
      view.setWantsLayer(true)
      view << rotatable_image_view(frame: [50,50,100,100],
                          image_filename: png_filename('zoom_2x2_128_031')) do |image_view|
        image_view.setFrameCenterRotation(image_view.frameCenterRotation + 45)
        image_view.delegate = RotatableImageController.new
      end
    end
  end
end

LightingPlanner.new.start
