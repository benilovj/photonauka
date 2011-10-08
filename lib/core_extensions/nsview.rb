class NSView
  def remove_subviews
    subviews.map(&:removeFromSuperview)
  end
end