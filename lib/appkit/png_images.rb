module PngImages
  def png_image(filename)
    NSImage.alloc.initWithContentsOfFile(png_filename(filename))
  end
  
  def png_filename(filename)
    NSBundle.mainBundle.pathForResource File.basename(filename), ofType:'png', inDirectory:File.dirname(filename)
  end
end