require 'lib/hotcocoa/mappings/appkit/rotatable_image_view'

require 'lib/models/floor_plan'
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
    if @floor_plan != floor_plan
      nc = NSNotificationCenter.defaultCenter
      if @floor_plan
        nc.removeObserver self, name:FLOOR_PLAN_CHANGE_NOTIFICATION, object:@floor_plan
      end
      @floor_plan = floor_plan
      nc.addObserver self, selector:'refresh', name:FLOOR_PLAN_CHANGE_NOTIFICATION, object:@floor_plan
      refresh
    end
  end
  
  def refresh
    remove_subviews
    image_view = HotCocoa.rotatable_image_view(frame: [0,0,100,100],
                                      image_filename: png_filename('zoom_2x2_128_031')) do |image_view|
      controller = RotatableImageController.new
      controller.floor_plan = @floor_plan
      image_view.delegate = controller
      image_view.setFrameCenterRotation(image_view.frameCenterRotation + 45)
      image_view.setFrameOrigin(@floor_plan.position)
    end
    addSubview image_view
    setNeedsDisplay true
  end
  
  protected
  def deselect_rotatable_images
    subviews.select {|view| view.is_a?(RotatableImageView)}.map(&:deselect)
  end
end
