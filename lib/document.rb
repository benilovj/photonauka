class MyDocument < NSDocument
  attr_accessor :view
  
  def init
    super
  end
  
  def printOperationWithSettings(printSettings, error:outError)
    NSPrintOperation.printOperationWithView @view, printInfo:printInfo
  end
end