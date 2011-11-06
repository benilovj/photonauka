require 'lib/models/device'

FLOOR_PLAN_CHANGE_NOTIFICATION = 'FLOOR_PLAN_CHANGE_NOTIFICATION'

class FloorPlan
  attr_reader :devices
  
  def undo_manager=(new_undo_manager)
    @devices.each {|device| device.undo_manager = new_undo_manager}
  end

  def initialize
    @devices = [Device.new(NSPoint.new(100,100), 45), Device.new(NSPoint.new(300,45), 145)]
    @devices.each do |device|
      NSNotificationCenter.defaultCenter.addObserver self, selector:'refresh', name:DEVICE_CHANGE_NOTIFICATION, object:device
    end
  end

  def encodeWithCoder(c)
    c.encodeObject @devices, forKey:'devices'
  end

  def initWithCoder(c)
    @devices = c.decodeObjectForKey('devices')
    self
  end

  def refresh
    NSNotificationCenter.defaultCenter.postNotificationName FLOOR_PLAN_CHANGE_NOTIFICATION,
      object:self, userInfo:nil
  end
end
