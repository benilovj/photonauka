class Project < NSDocument
  attr_accessor :view
  attr_accessor :floor_plan
  
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
  
  def view=(view)
    @view = view
    update_ui
  end
  
  def makeWindowControllers
    addWindowController(NSWindowController.new)
  end
  
  protected
  def update_ui
    @view.floor_plan = @floor_plan
  end
end