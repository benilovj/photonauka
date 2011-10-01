class MyDocument < NSDocument
  attr_accessor :view
  
  def init
    super
  end
  
  def updateUI
    @view.setFloorPlan @floor_plan
  end
  
  def dataOfType(type, error:outError)
    NSKeyedArchiver.archivedDataWithRootObject @floor_plan
  end

  def readFromData(data, ofType:type, error:outError)
    @floor_plan = NSKeyedUnarchiver.unarchiveObjectWithData data
    updateUI if @view
    true
  end
  
  def printOperationWithSettings(printSettings, error:outError)
    NSPrintOperation.printOperationWithView @view, printInfo:printInfo
  end
end