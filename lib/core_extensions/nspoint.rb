class NSPoint
  def +(other)
    NSPoint.new(self.x + other.x, self.y + other.y)
  end
  
  def -(other)
    NSPoint.new(self.x - other.x, self.y - other.y)
  end
  
  def to_s
    "(#{self.x},#{self.y})"
  end
end