framework 'Cocoa'
require 'hotcocoa'

require 'lib/core_extensions/cgrect'
require 'lib/core_extensions/nspoint'
require 'lib/core_extensions/nsview'

ROTATABLE_IMAGE_VIEW_SELECTION_NOTIFICATION = 'ROTATABLE_IMAGE_VIEW_SELECTION_NOTIFICATION'

class RotatableImageView < NSView
  IMAGE_INSET = 15

  GRIP_RADIUS = 3
  BORDER_INSET = IMAGE_INSET

  attr_accessor :delegate

  def initWithFrame(frame)
    super
    unless self.nil?
      deselect
      self.delegate = RotatableImageController.new
    end
    self
  end

  def filename=(filename)
    @image = NSImage.alloc.initWithContentsOfFile filename
  end

  def delegate=(new_delegate)
    @delegate = new_delegate
    @delegate.view = self
  end

  def drawRect(rect)
    draw_image
    draw_rotation_grips if @selected
  end

  def rotation
    frameCenterRotation
  end

  def rotation=(rotation)
    setFrameCenterRotation(rotation)
    @delegate.rotation = rotation
  end

  def selected?
    @selected
  end

  def select
    define_tracking_areas unless @selected
    @selected = true
    NSNotificationCenter.defaultCenter.postNotificationName ROTATABLE_IMAGE_VIEW_SELECTION_NOTIFICATION,
      object:self, userInfo:nil
    setNeedsDisplay(true)
  end

  def deselect
    self.trackingAreas.each {|area| removeTrackingArea(area)} if @selected
    @selected = false
    setNeedsDisplay(true)
  end
  
  def relative_location_of(event)
    self.convertPoint(event.locationInWindow, fromView: self)
  end
  
  def mouseEntered(event)
    @delegate.cursor_over_grip = true
  end

  def mouseExited(event)
    @delegate.cursor_over_grip = false
  end

  def mouseDown(event)
    @delegate.mouseDown(event)
  end

  def mouseDragged(event)
    @delegate.mouseDragged(event)
  end

  def mouseUp(event)
    @delegate.mouseUp(event)
  end
  
  protected
  def define_tracking_areas
    squares = border_corners.map {|point| CGRect.square_with_center(point, side_length: 8*GRIP_RADIUS)}
    for square in squares
      self.addTrackingArea(HotCocoa.tracking_area(rect: square,
                                               options: [:mouse_entered_and_exited, :active_in_key_window, :enabled_during_drag],
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
end