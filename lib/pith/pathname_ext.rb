require "pathname"

class Pathname

  def touch(mtime = nil)
    FileUtils.touch(self.to_s)
    utime(mtime, mtime) if mtime
  end

  def glob_all(pattern)
    Pathname.glob(self + pattern, File::FNM_DOTMATCH)
  end
  
end
