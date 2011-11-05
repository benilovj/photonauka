DEVICE_CHANGE_NOTIFICATION = 'DEVICE_CHANGE_NOTIFICATION'
FLOOR_PLAN_CHANGE_NOTIFICATION = 'FLOOR_PLAN_CHANGE_NOTIFICATION'

class Device
  attr_reader :position
  attr_reader :rotation
  attr_writer :undo_manager

  def initialize
    @position = NSPoint.new(100,100)
    @rotation = 45
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

class FloorPlan
  def undo_manager=(new_undo_manager)
    @device.undo_manager = new_undo_manager
  end

  def initialize
    @device = Device.new
    NSNotificationCenter.defaultCenter.addObserver self, selector:'refresh', name:DEVICE_CHANGE_NOTIFICATION, object:@device
  end

  def devices
    [@device]
  end

  def encodeWithCoder(c)
    c.encodeObject @device, forKey:'device'
  end

  def initWithCoder(c)
    @device = c.decodeObjectForKey('device')
    self
  end

  def position
    @device.position
  end

  def rotation
    @device.rotation
  end

  def position=(new_position)
    @device.position = new_position
  end

  def rotation=(new_rotation)
    @device.rotation = new_rotation
  end

  def refresh
    NSNotificationCenter.defaultCenter.postNotificationName FLOOR_PLAN_CHANGE_NOTIFICATION,
      object:self, userInfo:nil
  end
end
