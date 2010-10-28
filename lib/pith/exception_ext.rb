class Exception
  
  def summary
    (["#{self.class}: #{self.message}"] + self.backtrace).join("\n    ") + "\n"
  end
  
end
