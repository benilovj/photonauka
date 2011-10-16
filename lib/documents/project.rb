require 'lib/models/floor_plan'
require 'lib/appkit/project_window_factory'

class Project < NSDocument
  attr_accessor :floor_plan
  
  def init
    # the &nil part is a workaround for the warning:
    #  unknown: warning: passing a block to an Objective-C method - will be ignored
    # not sure where the warning comes from
    super(&nil)
    @floor_plan = FloorPlan.new
    @floor_plan.undo_manager = undoManager
    self
  end
  
  def dataOfType(type, error:outError)
    NSKeyedArchiver.archivedDataWithRootObject @floor_plan
  end

  def readFromData(data, ofType:type, error:outError)
    @floor_plan = NSKeyedUnarchiver.unarchiveObjectWithData data
    @floor_plan.undo_manager = undoManager
    true
  end
  
  def printOperationWithSettings(printSettings, error:outError)
    NSPrintOperation.printOperationWithView @view, printInfo:printInfo
  end
  
  def makeWindowControllers
    # it's a hack that the window factory is a singleton, but I don't see any other way around it
    # it has to preserve the state of the window cascade points because it doesn't seem to work otherwise
    new_window = ProjectWindowFactory.instance.make_new_window
    update_ui_with(new_window.view)
    addWindowController(NSWindowController.alloc.initWithWindow(new_window))
  end
  
  protected
  def update_ui_with(view)
    @view = view
    @view.floor_plan = @floor_plan
  end
end