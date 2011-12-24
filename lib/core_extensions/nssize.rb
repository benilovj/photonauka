module SizeOperations
  def encompases?(other)
    self.width > other.width and self.height > other.height
  end

  def *(constant)
    NSMakeSize(self.width * constant, self.height * constant)
  end

  def scaled_to_fit_into(bounding_box)
    min_ratio_that_fits_into_bounding_box = [bounding_box.height / self.height, bounding_box.width / self.width].min
    self * min_ratio_that_fits_into_bounding_box
  end

  def to_s
    "width: [#{self.width}], height: [#{self.height}]"
  end
end

class CGSize
  include SizeOperations
end

class NSSize
  include SizeOperations
end
