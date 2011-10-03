class CGRect
  def corner_points
    [[origin.x, origin.y], 
     [origin.x + size.width, origin.y],
     [origin.x + size.width, origin.y + size.height],
     [origin.x, origin.y + size.height]
     ].map {|x,y| NSMakePoint(x,y)}
  end
  
  def with_inset(inset)
    NSMakeRect(origin.x + inset, origin.y + inset, size.width - 2*inset, size.height - 2*inset)
  end
  
  class << self
    def square_with_center(center, side_length: length)
      NSMakeRect(center.x - length / 2, center.y - length / 2, length, length)
    end
  end
end