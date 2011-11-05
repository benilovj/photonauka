require 'appkit/floor_plan_view'

HotCocoa::Mappings.map floor_plan_view: FloorPlanView do
  defaults frame: CGRectZero

  def init_with_options view, options
    view.initWithFrame options.delete :frame
  end
end