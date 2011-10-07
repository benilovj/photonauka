begin
  require 'hotcocoa'
rescue LoadError
  require 'rubygems'
  require 'hotcocoa'
end

require 'lib/core_extensions'
require 'lib/document/project'

require 'lib/appkit/rotatable_image_view'
require 'lib/appkit/rotatable_image_controller'
require 'lib/hotcocoa/mappings/appkit/rotatable_image_view'
require 'lib/appkit/floor_plan_view'
require 'lib/hotcocoa/mappings/appkit/floor_plan_view'

class LightingSetup
  include HotCocoa
  include PngImages

  def initialize
    @document = Project.new
  end

  def start
    application name: 'Photonauka Lighting Setup' do |app|
      app.delegate = self
      @window = window frame: [100, 100, 500, 500], title: 'Lighting Setup' do |win|
        win.view = floor_plan_view(frame: [0,0,400,400], auto_resize: [:width, :height]) do |view|
          view.setWantsLayer(true)
          view << rotatable_image_view(frame: [50,50,100,100],
                              image_filename: png_filename('zoom_2x2_128_031')) do |image_view|
            image_view.setFrameCenterRotation(image_view.frameCenterRotation + 45)
            image_view.delegate = RotatableImageController.new
          end
        end
        win.will_close { exit }
      end
      
      @document.view = @window.view
      @window.setWindowController(NSWindowController.new)
      @window.windowController.setDocument(@document)
    end
  end
  
  def on_save_as(menu)    
    @document.saveDocumentAs(self)
  end
  
  # TODO: is this the right way of printing?
  def on_print(menu)
    print_operation = @document.printOperationWithSettings({}, error:nil)
    
    print_operation.runOperationModalForWindow(application.mainWindow,
                    delegate:self,
                    didRunSelector: "printed:",
                    contextInfo: nil)
  end
  
  def printed(sender)
  end
end

LightingSetup.new.start
