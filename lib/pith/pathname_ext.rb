require "pathname"

class Pathname
  
  def touch(mtime = nil)
    FileUtils.touch(self.to_s)
    utime(mtime, mtime) if mtime
  end
  
end
