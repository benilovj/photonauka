require 'spec_helper'

require 'core_extensions/nsview'

describe NSPoint do
  it "should be convertible to radial coordinates" do
    NSPoint.new(0,1).to_radial.length.should == 1
    NSPoint.new(0,1).to_radial.radians.should be_within(0.01).of(Math::PI / 2)
  end
end

describe RadialPoint do
  it "should provide degrees" do
    RadialPoint.new(Math::PI, 1).degrees.should be_within(0.01).of(180)
  end
end