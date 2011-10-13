require 'lib/hotcocoa/mappings/appkit/floor_plan_view'

module ProjectWindowFactory
  include HotCocoa
  
  def make_project_window
    window do |win|
        win.view = floor_plan_view(auto_resize: [:width, :height]) do |view|
        view.setWantsLayer(true)
      end
    end
  end
end