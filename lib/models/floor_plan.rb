class FloorPlan
  attr_accessor :position
  
  def initialize
    @position = NSMakePoint(100,100)
  end
  
  def encodeWithCoder(c)
    c.encodeObject [@position.x, @position.y], forKey:'position'
  end
  
  def initWithCoder(c)
    coords = c.decodeObjectForKey('position')
    @position = NSMakePoint(coords.first, coords.last)
    self
  end
  
  def position=(new_position)
    @position = new_position
  end
  
  def to_s
    "Position = #{@position}"
  end
end
