require 'lib/hotcocoa/mappings/appkit/rotatable_image_view'

require 'lib/models/floor_plan'
require 'lib/appkit/rotatable_image_controller'
require 'lib/appkit/png_images'

class FloorPlanView < NSView
  TRACKPAD_ROTATION_SENSITIVITY = 3

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

  def rotateWithEvent(event)
    selected_image.rotation += TRACKPAD_ROTATION_SENSITIVITY * event.rotation unless selected_image.nil?
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
    @device_presenters.values.map(&:refresh)
    setNeedsDisplay true
  end

  def prepare_for_printing
    deselect_rotatable_images
  end

  def cursorUpdate(event)
    rotation_occuring? ? NSCursor.rotateCursor.set : NSCursor.arrowCursor.set
  end

  protected
  def initial_refresh
    @device_presenters = {}
    @floor_plan.devices.each do |device|
      view = HotCocoa.rotatable_image_view(frame: [0,0,100,100], image_filename: png_filename('zoom_2x2_128_031'))
      addSubview view
      NSNotificationCenter.defaultCenter.addObserver self, selector:'deselect_all_but_selected:', name:ROTATABLE_IMAGE_VIEW_SELECTION_NOTIFICATION, object:view
      @device_presenters[device] = view.presenter
      view.presenter.device = device
    end
  end

  def deselect_rotatable_images
    rotatable_images.map(&:deselect)
  end

  def rotation_occuring?
    rotatable_images.map(&:presenter).any?(&:rotation_occuring?)
  end

  def selected_image
    rotatable_images.detect(&:selected?)
  end

  def deselect_all_but_selected(notification)
    (rotatable_images - [notification.object]).map(&:deselect)
  end

  def rotatable_images
    subviews.select {|view| view.is_a?(RotatableImageView)}
  end
end
