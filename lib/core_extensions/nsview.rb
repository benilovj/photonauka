require 'lib/core_extensions/nspoint'

class NSView
  include Math
  
  def center=(new_center)
    setFrameOrigin(non_rotated_origin_given(new_center))
  end
  
  protected
  def non_rotated_origin_given(center)
    rotation = self.frameCenterRotation.to_f * PI / 180
    w, h = frame.size.width.to_f, frame.size.height.to_f

    x_shift = ((sqrt(w**2 + h**2))/2) * sin(rotation - atan(w/h))
    y_shift = ((sqrt(w**2 + h**2))/2) * cos(rotation - atan(w/h))
    
    center + NSPoint.new(x_shift, -1 * y_shift)
  end
end