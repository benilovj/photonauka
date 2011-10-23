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