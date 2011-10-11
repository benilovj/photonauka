begin
  require 'hotcocoa'
rescue LoadError
  require 'rubygems'
  require 'hotcocoa'
end

require 'lib/core_extensions'
require 'lib/documents/project'
require 'lib/models/floor_plan'

require 'lib/appkit/rotatable_image_view'
require 'lib/appkit/rotatable_image_controller'
require 'lib/hotcocoa/mappings/appkit/rotatable_image_view'
require 'lib/appkit/floor_plan_view'
require 'lib/hotcocoa/mappings/appkit/floor_plan_view'

class LightingSetup
  include HotCocoa
  include PngImages

  def initialize
    @project = Project.new
    @project.floor_plan = FloorPlan.new
    NSDocumentController.sharedDocumentController.addDocument(@project)
  end

  def start
    application do |app|
      app.delegate = self
      @window = window frame: [100, 100, 500, 500], title: 'Lighting Setup' do |win|
        win.view = floor_plan_view(frame: [0,0,400,400], auto_resize: [:width, :height]) do |view|
          view.setWantsLayer(true)
          view.floor_plan = @project.floor_plan
        end
        win.will_close { exit }
      end
      
      @project.view = @window.view
    end
  end
  
  def on_save_as(menu)    
    @project.saveDocumentAs(self)
  end

  # TODO: this feels very very hacky
  # also, why doesn't doc controller manage the currentDocument properly?
  def on_open(menu)
    doc_controller.removeDocument(@project)
    doc_controller.openDocument(self)
    @project = doc_controller.documents.first
    @project.view = @window.view
  end
  
  # TODO: is this the right way of printing?
  def on_print(menu)
    print_operation = @project.printOperationWithSettings({}, error:nil)
    
    print_operation.runOperationModalForWindow(application.mainWindow,
                    delegate:self,
                    didRunSelector: "printed:",
                    contextInfo: nil)
  end
  
  def printed(sender)
  end
  
  protected
  def doc_controller
    NSDocumentController.sharedDocumentController
  end
end

LightingSetup.new.start
