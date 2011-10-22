RSpec::Matchers.define :be_near_point do |expected_x, expected_y|
  match do |actual|
    Math.sqrt((actual.x - expected_x)**2 + (actual.y - expected_y)**2) < 0.01
  end
end