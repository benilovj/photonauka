require 'spec_helper'

require 'hotcocoa'
require 'core_extensions/nsview'

describe NSView do
  include HotCocoa
  
  context "for an unrotated view" do
    subject do
      view = view(frame: [0, 0, 10, 20])
      superview = view {|s| s << view}
      view
    end
    
    it "should move the frame origin when the center is moved" do
      subject.center = NSPoint.new(0,0)
      subject.frame.origin.should be_near_point(-5, -10)
    end
  end
  
  context "for a rotated view" do
    subject do
      view = view(frame: [0, 0, 10, 20])
      superview = view {|s| s << view}
      view.setFrameCenterRotation(45)
      view
    end
    
    it "should move the frame origin when the center is moved" do
      subject.center = NSPoint.new(0,0)
      subject.setFrameCenterRotation(0)
      subject.frame.origin.should be_near_point(-5, -10)
    end
  end
end