class Exception
  
  def summary(options = {})
    max_backtrace = options[:max_backtrace] || 999
    trimmed_backtrace = self.backtrace[0, max_backtrace]
    (["#{self.class}: #{self.message}"] + trimmed_backtrace).join("\n    ") + "\n"
  end
  
end
