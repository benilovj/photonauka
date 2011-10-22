framework 'Cocoa'
require 'hotcocoa'

require 'lib/core_extensions/cgrect'
require 'lib/core_extensions/nspoint'
require 'lib/core_extensions/nsview'

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
  
  attr_accessor :delegate
  
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
    @initial_location = self.convertPoint(event.locationInWindow, fromView: self)
    @initial_origin = frame.origin
    
    self.selected = true
  end
  
  def mouseDragged(event)
    delta = self.convertPoint(event.locationInWindow, fromView: self) - @initial_location
    self.setFrameOrigin @initial_origin + delta
  end

  def mouseUp(event)
    delta = self.convertPoint(event.locationInWindow, fromView: self) - @initial_location
    @delegate.shift_by(delta)
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