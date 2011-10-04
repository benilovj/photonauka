module PngImages
  def png_file(filename)
    NSImage.alloc.initWithContentsOfFile(png_filename(filename))
  end
  
  def png_filename(filename)
    NSBundle.mainBundle.pathForResource filename, ofType:'png'
  end
end