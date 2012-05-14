require "pathname"

class Pathname

  def touch(mtime = nil)
    FileUtils.touch(self.to_s)
    utime(mtime, mtime) if mtime
  end

  def in?(dir)
    prefix = "#{dir}/"
    self.to_s[0,prefix.length] == prefix
  end

end
