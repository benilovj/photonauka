framework 'Foundation'

class RadialPoint < Struct.new(:radians, :length)
  def degrees
    (radians * 180) / Math::PI
  end
end

class NSPoint
  def +(other)
    NSPoint.new(self.x + other.x, self.y + other.y)
  end

  def -(other)
    NSPoint.new(self.x - other.x, self.y - other.y)
  end

  def to_radial
    RadialPoint.new(radians, length)
  end

  def to_s
    "(#{self.x},#{self.y})"
  end

  protected
  def radians
    Math.atan2(y.to_f, x.to_f)
  end

  def length
    Math.sqrt(x**2 + y**2)
  end
end