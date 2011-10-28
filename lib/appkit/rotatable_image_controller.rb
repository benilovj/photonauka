require 'lib/core_extensions/nspoint'

class RotatableImageController
  attr_accessor :view
  
  def shift_by(delta)
    @floor_plan.position += delta
  end
  
  def rotation=(rotation)
    @floor_plan.rotation = rotation
  end
  
  def floor_plan=(new_floor_plan)
    @floor_plan = new_floor_plan
    @view.setFrameCenterRotation(@floor_plan.rotation)
    @view.center = @floor_plan.position
  end
  
  def mouseEntered(event)
    @cursor_over_grip = true
    update_cursor
  end

  def mouseExited(event)
    @cursor_over_grip = false
    update_cursor
  end
  
  def mouseDown(event)
    @mouse_pressed = true
    update_cursor
    view.select

    @rotation_occuring = @cursor_over_grip

    if @rotation_occuring
      @initial_rotation = view.frameCenterRotation
      @initial_angle = (view.relative_location_of(event) - view.center).to_radial.degrees
    else
      @initial_location = view.relative_location_of(event)
      @initial_origin = view.frame.origin
    end
  end
  
  def mouseDragged(event)
    if @rotation_occuring
      delta = view.relative_location_of(event) - view.center
      view.setFrameCenterRotation(@initial_rotation + delta.to_radial.degrees - @initial_angle)
    else
      delta = view.relative_location_of(event) - @initial_location
      view.setFrameOrigin @initial_origin + delta
    end
  end

  def mouseUp(event)
    @mouse_pressed = false
    update_cursor

    if @rotation_occuring
      delta = view.relative_location_of(event) - view.center
      self.rotation = @initial_rotation + delta.to_radial.degrees - @initial_angle
    else
      delta = view.relative_location_of(event) - @initial_location
      shift_by(delta)
    end

    @rotation_occuring = false
  end

  protected
  def update_cursor
    return if NSCursor.currentCursor.nil?
    case
    when (@cursor_over_grip and @mouse_pressed) then rotate_cursor.set
    when (@cursor_over_grip and not @mouse_pressed) then NSCursor.openHandCursor.set
    else NSCursor.arrowCursor.set
    end
  end
  
  def rotate_cursor
    @rotate_cursor ||= load_rotate_cursor
  end
  
  def load_rotate_cursor
    image_name = NSBundle.mainBundle.pathForResource 'rotate_cursor', ofType:'png'
    image = NSImage.alloc.initWithContentsOfFile(image_name)
    NSCursor.alloc.initWithImage(image, hotSpot:[7,7])
  end
end