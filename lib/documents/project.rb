require 'lib/models/floor_plan'
require 'lib/appkit/project_window_factory'

class Project < NSDocument
  include ProjectWindowFactory
  
  attr_accessor :floor_plan
  
  def init
    super
    @floor_plan = FloorPlan.new
    self
  end
  
  def dataOfType(type, error:outError)
    NSKeyedArchiver.archivedDataWithRootObject @floor_plan
  end

  def readFromData(data, ofType:type, error:outError)
    @floor_plan = NSKeyedUnarchiver.unarchiveObjectWithData data
    true
  end
  
  def printOperationWithSettings(printSettings, error:outError)
    NSPrintOperation.printOperationWithView @view, printInfo:printInfo
  end
  
  def makeWindowControllers
    new_window = make_project_window
    NSLog("window visible: #{new_window.isVisible}")
    @view = new_window.view
    update_ui
    addWindowController(NSWindowController.alloc.initWithWindow(new_window))
  end
  
  protected
  def update_ui
    @view.floor_plan = @floor_plan
  end
end