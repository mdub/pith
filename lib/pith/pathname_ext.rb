require "pathname"

class Pathname

  def touch(mtime = nil)
    FileUtils.touch(self.to_s)
    utime(mtime, mtime) if mtime
  end

  def all_files(pattern = "**/*")
    Pathname.glob(self + pattern, File::FNM_DOTMATCH).select do |path|
      path.file?
    end
  end

  def in?(dir)
    prefix = "#{dir}/"
    self.to_s[0,prefix.length] == prefix
  end

end
