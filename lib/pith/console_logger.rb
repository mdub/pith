module Pith
  
  class ConsoleLogger
    
    def initialize(out = STDOUT, err = STDERR)
      @out = out
      @err = err
    end

    def info(message, &block)
      message ||= block.call
      @out.puts(message)
    end

    def warn(message, &block)
      message ||= block.call
      @err.puts(message)
    end

    def error(message, &block)
      message ||= block.call
      @err.puts("ERROR: " + message)
    end
    
  end
  
end