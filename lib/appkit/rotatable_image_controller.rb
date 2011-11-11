require 'lib/core_extensions/nspoint'
require 'lib/core_extensions/nscursor'

class RotationResponder
  def initialize(controller, view)
    @controller = controller
    @view = view
  end

  def mouse_down_at(relative_location)
    @degrees_between_frame_rotation_and_grip_vector = @view.frameCenterRotation - grip_vector_degrees_given(relative_location)
  end

  def mouse_dragged_at(relative_location)
    @view.setFrameCenterRotation(grip_vector_degrees_given(relative_location) + @degrees_between_frame_rotation_and_grip_vector)
  end

  def mouse_up_at(relative_location)
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

  def mouse_down_at(relative_location)
    @initial_location = relative_location
    @initial_origin = @view.frame.origin
  end

  def mouse_dragged_at(relative_location)
    delta = relative_location- @initial_location
    @view.setFrameOrigin @initial_origin + delta
  end

  def mouse_up_at(relative_location)
    delta = relative_location - @initial_location
    @controller.shift_by(delta)
  end
end

class RotatableImageController
  attr_accessor :view
  attr_accessor :cursor_over_grip

  def view=(new_view)
    @view = new_view
    @rotation_responder = RotationResponder.new(self, new_view)
    @dragging_responder = DraggingResponder.new(self, new_view)
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

  def mouse_down_at(location)
    @rotation_occuring = @cursor_over_grip
    view.select
    appropriate_responder.mouse_down_at(location)
  end
  
  def mouse_dragged_at(location)
    appropriate_responder.mouse_dragged_at(location)
  end

  def mouse_up_at(location)
    appropriate_responder.mouse_up_at(location)
    @rotation_occuring = false
  end

  def rotation_occuring?
    @rotation_occuring
  end

  protected
  def appropriate_responder
    rotation_occuring? ? @rotation_responder : @dragging_responder
  end
end