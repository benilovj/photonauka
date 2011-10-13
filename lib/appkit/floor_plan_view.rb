framework 'Cocoa'

require 'lib/hotcocoa/mappings/appkit/rotatable_image_view'

require 'lib/appkit/rotatable_image_controller'
require 'lib/appkit/png_images'

class FloorPlanView < NSView
  include PngImages
  
  def mouseDown(event)
    deselect_rotatable_images
  end
  
  def drawRect(rect)
    NSColor.colorWithPatternImage(png_file('grid')).setFill
    NSRectFill(bounds)
  end
  
  def floor_plan=(floor_plan)
    remove_subviews
    image_view = HotCocoa.rotatable_image_view(frame: [0,0,100,100],
                                      image_filename: png_filename('zoom_2x2_128_031')) do |image_view|
      controller = RotatableImageController.new
      controller.floor_plan = floor_plan
      image_view.delegate = controller
      image_view.setFrameCenterRotation(image_view.frameCenterRotation + 45)
      image_view.setFrameOrigin(floor_plan.position)
    end
    addSubview image_view
  end
  
  protected
  def deselect_rotatable_images
    subviews.select {|view| view.is_a?(RotatableImageView)}.map(&:deselect)
  end
end
