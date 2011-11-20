require 'lib/hotcocoa/mappings/appkit/rotatable_image_view'

require 'lib/models/floor_plan'
require 'lib/appkit/rotatable_image_presenter'
require 'lib/appkit/png_images'

class FloorPlanView < NSView
  include PngImages

  def mouseDown(event)
    deselect_devices
  end

  def drawRect(rect)
    NSColor.colorWithPatternImage(png_image('grid')).setFill
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
    initial_refresh if devices.empty?
    @device_presenters.values.map(&:refresh)
    setNeedsDisplay true
  end

  def prepare_for_printing
    deselect_devices
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
      NSNotificationCenter.defaultCenter.addObserver self, selector:'deselect_all_but_selected:', name:ROTATABLE_IMAGE_VIEW_SELECTION_NOTIFICATION, object:view.presenter
      @device_presenters[device] = view.presenter
      view.presenter.device = device
    end
  end

  def deselect_devices
    devices.map(&:deselect)
  end

  def rotation_occuring?
    devices.any?(&:rotation_occuring?)
  end

  def deselect_all_but_selected(notification)
    (devices - [notification.object]).map(&:deselect)
  end

  def devices
    subviews.select {|view| view.is_a?(RotatableImageView)}.map(&:presenter)
  end
end
