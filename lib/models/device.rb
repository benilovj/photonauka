DEVICE_CHANGE_NOTIFICATION = 'DEVICE_CHANGE_NOTIFICATION'

class Device
  attr_reader :position
  attr_reader :rotation
  attr_writer :undo_manager

  def initialize(position, rotation)
    @position = position
    @rotation = rotation
  end

  def encodeWithCoder(c)
    c.encodeObject [@position.x, @position.y], forKey:'position'
    c.encodeObject @rotation, forKey:'rotation'
  end

  def initWithCoder(c)
    coords = c.decodeObjectForKey('position')
    @position = NSPoint.new(coords.first, coords.last)
    @rotation = c.decodeObjectForKey('rotation')
    self
  end
  
  def position=(new_position)
    old_position = @position
    if new_position != old_position
      obj = @undo_manager.prepareWithInvocationTarget self
      obj.position = old_position
      @position = new_position
      NSNotificationCenter.defaultCenter.postNotificationName DEVICE_CHANGE_NOTIFICATION,
        object:self, userInfo:nil
    end
  end
  
  def rotation=(new_rotation)
    old_rotation = @rotation
    if new_rotation != old_rotation
      obj = @undo_manager.prepareWithInvocationTarget self
      obj.rotation = old_rotation
      @rotation = new_rotation
      NSNotificationCenter.defaultCenter.postNotificationName DEVICE_CHANGE_NOTIFICATION,
        object:self, userInfo:nil
    end
  end
  
  def to_s
    "Position = #{@position}, rotation = #{@rotation}"
  end
end