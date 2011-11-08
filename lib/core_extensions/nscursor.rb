class NSCursor
  def self.rotateCursor
    @@rotate_cursor ||= load_rotate_cursor
  end
  
  def self.load_rotate_cursor
    image_name = NSBundle.mainBundle.pathForResource 'rotate_cursor', ofType:'png'
    image = NSImage.alloc.initWithContentsOfFile(image_name)
    NSCursor.alloc.initWithImage(image, hotSpot:[9, 9])
  end
end