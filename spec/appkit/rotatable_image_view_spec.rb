require 'spec_helper'

require 'appkit/rotatable_image_view'
require 'hotcocoa/mappings/appkit/rotatable_image_view'
require 'appkit/rotatable_image_controller'

describe RotatableImageView do
  include HotCocoa
  before do
    @device = Struct.new(:position, :rotation).new(NSPoint.new(0, 0), 0)
    
    @view = rotatable_image_view(frame: [-10, -5, 20, 10])
    @view.presenter.device = @device
    view(frame: [0, 0, 100, 100]) do |v|
      v << @view
    end
  end
  
  it "should drag" do
    @view.frame.origin.should be_near_point(-10, -5)

    starting_drag = mock("event", :locationInWindow => NSPoint.new(1, 1))
    @view.mouseDown(starting_drag)

    mid_drag = mock("event", :locationInWindow => NSPoint.new(5, 1))
    @view.mouseDragged(mid_drag)
    @view.frame.origin.should be_near_point(-6, -5)
    @device.position.should be_near_point(0, 0)

    ending_drag = mock("event", :locationInWindow => NSPoint.new(6, 2))
    @view.mouseDragged(ending_drag)
    @view.mouseUp(ending_drag)
    @view.frame.origin.should be_near_point(-5, -4)
    @device.position.should be_near_point(5, 1)
    @device.rotation.should == 0
  end
  
  it "should rotate" do
    @view.frame.origin.should be_near_point(-10, -5)

    hovering_over_grip = mock("event", :locationInWindow => NSPoint.new(-10, -5))
    @view.mouseEntered(hovering_over_grip)

    starting_drag = mock("event", :locationInWindow => NSPoint.new(-10, -5))
    @view.mouseDown(starting_drag)

    mid_drag = mock("event", :locationInWindow => NSPoint.new(-5, 0))
    @view.mouseDragged(mid_drag)
    @device.position.should be_near_point(0, 0)
    @device.rotation.should == 0

    ending_drag = mock("event", :locationInWindow => NSPoint.new(10, 5))
    @view.mouseDragged(ending_drag)
    @view.mouseUp(ending_drag)
    @view.frame.origin.should be_near_point(10, 5)
    @device.position.should be_near_point(0, 0)
    @device.rotation.should be_within(0.01).of(180.0)
  end
end