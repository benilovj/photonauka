class NSRect
  def to_s
    "origin: (#{origin.x}, #{origin.y}), size: (height: #{size.height}, width: #{size.width})"
  end
end