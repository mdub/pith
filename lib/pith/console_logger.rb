module Pith
  
  class ConsoleLogger
    
    def initialize(io = STDOUT)
      @io = io
    end

    def info(message, &block)
      message ||= block.call
      @io.puts(message)
    end
    
    def write(message)
      @io.puts(message)
    end
    
  end
  
end