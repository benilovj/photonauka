require 'lib/core_extensions/nspoint'
require 'lib/core_extensions/nscursor'

class RotationResponder
  def initialize(controller, view)
    @controller = controller
    @view = view
  end

  def mouseDown(relative_location)
    @degrees_between_frame_rotation_and_grip_vector = @view.frameCenterRotation - grip_vector_degrees_given(relative_location)
  end

  def mouseDragged(relative_location)
    @view.setFrameCenterRotation(grip_vector_degrees_given(relative_location) + @degrees_between_frame_rotation_and_grip_vector)
  end

  def mouseUp(relative_location)
    @controller.rotation = grip_vector_degrees_given(relative_location) + @degrees_between_frame_rotation_and_grip_vector
  end

  protected
  def grip_vector_degrees_given(relative_location)
    (relative_location - @view.center).to_radial.degrees
  end
end

class DraggingResponder
  def initialize(controller, view)
    @controller = controller
    @view = view
  end

  def mouseDown(relative_location)
    @initial_location = relative_location
    @initial_origin = @view.frame.origin
  end

  def mouseDragged(relative_location)
    delta = relative_location- @initial_location
    @view.setFrameOrigin @initial_origin + delta
  end

  def mouseUp(relative_location)
    delta = relative_location - @initial_location
    @controller.shift_by(delta)
  end
end

class RotatableImageController
  attr_accessor :view

  def view=(new_view)
    @view = new_view
    @rotation_responder = RotationResponder.new(self, new_view)
    @dragging_responder = DraggingResponder.new(self, new_view)
  end

  def cursor_over_grip=(new_cursor_over_grip)
    @cursor_over_grip = new_cursor_over_grip
    update_cursor
  end

  def shift_by(delta)
    @device.position += delta
  end

  def rotation=(rotation)
    @device.rotation = rotation
  end

  def device=(new_device)
    @device = new_device
  end

  def refresh
    @view.setFrameCenterRotation(@device.rotation)
    @view.center = @device.position
  end

  def mouseExited(event)
    @cursor_over_grip = false
    update_cursor
  end

  def mouseDown(event)
    @rotation_occuring = @cursor_over_grip
    @mouse_pressed = true
    update_cursor
    view.select

    appropriate_responder.mouseDown(@view.relative_location_of(event))
  end
  
  def mouseDragged(event)
    appropriate_responder.mouseDragged(@view.relative_location_of(event))
  end

  def mouseUp(event)
    @mouse_pressed = false
    update_cursor

    appropriate_responder.mouseUp(@view.relative_location_of(event))

    @rotation_occuring = false
  end

  def rotation_occuring?
    @rotation_occuring
  end

  protected
  def appropriate_responder
    @rotation_occuring ? @rotation_responder : @dragging_responder
  end
  
  def update_cursor
    return if NSCursor.currentCursor.nil?
    case
    when @rotation_occuring then NSCursor.rotateCursor.set
    when (@cursor_over_grip and not @mouse_pressed) then NSCursor.openHandCursor.set
    else NSCursor.arrowCursor.set
    end
  end
end