require 'lib/core_extensions/nssize'
require 'lib/hotcocoa/mappings/appkit/floor_plan_view'
require 'lib/appkit/png_images'

class DeviceRepresentation < Struct.new(:device_id, :description)
  def filename
    'zoom_2x2_128pc/zoom_2x2_128_%03d' % device_id
  end
end

class NSImage
  def that_fits_into(bounding_box)
    resized_to(self.size.scaled_to_fit_into(bounding_box))
  end

  def resized_to(new_size)
    new_image = NSImage.alloc.initWithSize(new_size)
    old_rect = [0.0, 0.0, self.size.width, self.size.height]
    new_rect = [0.0, 0.0, new_size.width, new_size.height]

    new_image.lockFocus
    self.drawInRect(new_rect, fromRect:old_rect, operation:NSCompositeCopy, fraction:1.0)
    new_image.unlockFocus
    new_image
  end
end

DEVICE_REPRESENTATIONS = {
  "Models" => [
    DeviceRepresentation.new(26, "Model (boy)"),
    DeviceRepresentation.new(105, "Model (girl)"),
    DeviceRepresentation.new(27, "Subject"),
    DeviceRepresentation.new(28, "Car"),
    DeviceRepresentation.new(29, "Couch"),
    DeviceRepresentation.new(30, "Chair"),
    DeviceRepresentation.new(31, "Custom Size")],
  "Strobe Lighting" => [
    DeviceRepresentation.new(32, "Strobe"),
    DeviceRepresentation.new(33, "Strobe / Grid"),
    DeviceRepresentation.new(34, "Strobe / Gel"),
    DeviceRepresentation.new(35, "Strobe / Snoot"),
    DeviceRepresentation.new(36, "Strobe / Barndoors"),
    DeviceRepresentation.new(98, "Strobe / Boom / Softbox"),
    DeviceRepresentation.new(37, "Strobe / Boom"),
    DeviceRepresentation.new(38, "Strobe / Boom / Grid"),
    DeviceRepresentation.new(39, "Strobe / Boom / Ring Flash"),
    DeviceRepresentation.new(40, "Strobe / Boom / Beauty Dish"),
    DeviceRepresentation.new(41, "Beauty Dish"),
    DeviceRepresentation.new(42, "Beauty Dish / Diffuser"),
    DeviceRepresentation.new(43, "On Camera Flash"),
    DeviceRepresentation.new(133, "Zoom Spot"),
    DeviceRepresentation.new(44, "Ring Flash")]
}

class ProjectWindowFactory
  include HotCocoa
  include PngImages
  
  def initialize
    @window_cascade_point = NSPoint.new(1,1)
  end
  
  class << self
    # yuck.
    # it'd be nice if this weren't a singleton, but I don't see any other way of preserving the cascading behaviour
    # and injecting this factory into the NSDocument subclass
    def instance
      @instance ||= ProjectWindowFactory.new
    end
  end

  DEVICE_CATALOG_PANEL_WIDTH = 220

  def make_new_window
    window(frame: [@window_cascade_point.x, @window_cascade_point.y, 700 + DEVICE_CATALOG_PANEL_WIDTH + 20, 700], view: :nolayout) do |win|
      @window_cascade_point = win.cascadeTopLeftFromPoint(@window_cascade_point)
      
      win.view = split_view(frame: win.view.bounds, auto_resize: [:width, :height], divider_style: :thin) do |split_view|

        split_view.horizontal = false
        split_view << floor_plan_view(auto_resize: [:width, :height]) do |view|
          view.setWantsLayer(true)
        end

        # TODO: i18nize the window title
        device_catalog = view(frame: [100, 100, DEVICE_CATALOG_PANEL_WIDTH + 20, 380]) do |subview|
          chooser = popup(frame: [0, 330, DEVICE_CATALOG_PANEL_WIDTH + 20, 40]) do |popup|
            popup.items = DEVICE_REPRESENTATIONS.keys
          end
          subview << chooser
          @matrix = matrix_for(DEVICE_REPRESENTATIONS[chooser.items.selected])
          chooser.on_action do |c|
            @matrix.removeFromSuperview
            @matrix = matrix_for(DEVICE_REPRESENTATIONS[c.items.selected])
            subview << @matrix
          end
          subview << @matrix
        end
        split_view << device_catalog

        split_view.can_collapse_subview? {|v| v == device_catalog}
        split_view.should_adjust_size_of_subview? {|v| v != device_catalog}
        split_view.constrain_min_coordinate_of_subview_with_index {|min_coord, index| win.frame.size.width - DEVICE_CATALOG_PANEL_WIDTH - 30}
        split_view.constrain_max_coordinate_of_subview_with_index {|max_coord, index| win.frame.size.width - DEVICE_CATALOG_PANEL_WIDTH - 30}
      end
    end
  end

  def matrix_for(device_representations)
    scroll_view(frame: [0, 0, DEVICE_CATALOG_PANEL_WIDTH + 20, 320]) do |scroll|
      scroll.horizontal_scroller = false
      scroll << matrix(frame: [0, 0, DEVICE_CATALOG_PANEL_WIDTH, 40 * device_representations.size + 20], rows: device_representations.size, columns: 1, mode: :radio, cell_class: NSButtonCell) do |matrix|
        matrix.cell_size = [DEVICE_CATALOG_PANEL_WIDTH, 40]
        (0...device_representations.size).each do |i|
          matrix[i, 0].setImage(png_image(device_representations[i].filename).resized_to(NSMakeSize(40, 40)))
          matrix[i, 0].setTitle(device_representations[i].description)
          matrix[i, 0].setBezelStyle(NSThickerSquareBezelStyle)
          matrix[i, 0].setButtonType(NSMomentaryChangeButton)
          matrix[i, 0].setImageScaling(NSImageScaleProportionallyUpOrDown)
          matrix[i, 0].setImagePosition(NSImageLeft)
          matrix[i, 0].setShowsBorderOnlyWhileMouseInside(true)
          matrix[i, 0].setShowsStateBy( NSChangeGrayCellMask | NSChangeBackgroundCellMask)
          matrix[i, 0].setAlignment(NSLeftTextAlignment)
        end
      end
    end
  end
end