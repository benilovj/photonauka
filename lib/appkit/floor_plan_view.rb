framework 'Cocoa'
require 'lib/appkit/png_images'
require 'lib/appkit/rotatable_image_view'

class FloorPlanView < NSView
  include PngImages
  
  attr_writer :floor_plan
  
  def mouseDown(event)
    deselect_rotatable_images
  end
  
  def drawRect(rect)
    NSColor.colorWithPatternImage(png_file('grid')).setFill
    NSRectFill(bounds)
  end
  
  protected
  def deselect_rotatable_images
    subviews.select {|view| view.is_a?(RotatableImageView)}.map(&:deselect)
  end
end
