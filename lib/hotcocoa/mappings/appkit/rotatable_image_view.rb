require 'lib/appkit/rotatable_image_view'

HotCocoa::Mappings.map rotatable_image_view: RotatableImageView do
  defaults frame: CGRectZero

  def init_with_options image_view, options
    view = image_view.initWithFrame options.delete :frame
    view.filename = options.delete(:image_filename)
    view
  end
end