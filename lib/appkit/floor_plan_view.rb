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
  
  def rotation=(rotation)
    rotatable_images.first.rotation = rotation
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
    initial_refresh if rotatable_images.empty?
    @device_controller.floor_plan = @floor_plan
    setNeedsDisplay true
  end
  
  protected
  def initial_refresh
    view = HotCocoa.rotatable_image_view(frame: [0,0,100,100], image_filename: png_filename('zoom_2x2_128_031'))
    addSubview view
    @device_controller = view.delegate
  end
  
  def deselect_rotatable_images
    rotatable_images.map(&:deselect)
  end
  
  def rotatable_images
    subviews.select {|view| view.is_a?(RotatableImageView)}
  end
end
