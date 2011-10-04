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