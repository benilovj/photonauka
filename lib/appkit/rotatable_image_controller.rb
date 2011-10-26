require 'lib/core_extensions/nspoint'

class RotatableImageController
  attr_writer :floor_plan
  attr_reader :view
  
  def rotation_started
    rotate_cursor.set
  end
  
  def rotation_finished
    NSCursor.arrowCursor.set
  end
  
  def mouse_over_grip
    NSCursor.openHandCursor.set
  end
  
  def shift_by(delta)
    @floor_plan.position += delta
  end
  
  def rotation=(rotation)
    @floor_plan.rotation = rotation
  end
  
  def view=(view)
    @view = view
    @view.delegate = self
  end
  
  def floor_plan=(new_floor_plan)
    @floor_plan = new_floor_plan
    @view.setFrameCenterRotation(@floor_plan.rotation)
    @view.center = @floor_plan.position
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

    @rotation_occuring = @cursor_over_grip

    if @rotation_occuring
      @initial_rotation = view.frameCenterRotation
      @initial_angle = (view.relative_location_of(event) - view.center).to_radial.degrees
    else
      @initial_location = view.relative_location_of(event)
      @initial_origin = view.frame.origin
    end
    
    view.select
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
    fire_events_if_needed
    
    if @rotation_occuring
      delta = view.relative_location_of(event) - view.center
      view.rotation = @initial_rotation + delta.to_radial.degrees - @initial_angle
    else
      delta = view.relative_location_of(event) - @initial_location
      shift_by(delta)
    end

    @rotation_occuring = false
  end
  
  protected
  def fire_events_if_needed
    case
    when (@cursor_over_grip and @mouse_pressed) then rotation_started
    when (@cursor_over_grip and not @mouse_pressed) then mouse_over_grip
    else rotation_finished
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