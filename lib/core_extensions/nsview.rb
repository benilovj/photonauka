framework 'AppKit'

require 'core_extensions/nspoint'

class NSView
  include Math
  
  def center=(new_center)
    setFrameOrigin(new_center + vector_from_center_to_origin)
  end
  
  def center
    frame.origin - vector_from_center_to_origin
  end
  
  protected
  def vector_from_center_to_origin
    rotation = self.frameCenterRotation.to_f * PI / 180
    w, h = frame.size.width.to_f, frame.size.height.to_f

    x_shift =      ((sqrt(w**2 + h**2))/2) * sin(rotation - atan(w/h))
    y_shift = -1 * ((sqrt(w**2 + h**2))/2) * cos(rotation - atan(w/h))
    
    NSPoint.new(x_shift, y_shift)
  end
end