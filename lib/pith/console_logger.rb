module Pith

  class ConsoleLogger

    def initialize(out = STDOUT, err = STDERR)
      @out = out
      @err = err
    end

    def debug(message = nil, &block)
      if ENV["PITH_DEBUG"]
        message ||= block.call
        @out.puts("DEBUG: " + message)
      end
    end

    def info(message = nil, &block)
      message ||= block.call
      @out.puts(message)
    end

    def warn(message = nil, &block)
      message ||= block.call
      @err.puts(message)
    end

    def error(message = nil, &block)
      message ||= block.call
      @err.puts("ERROR: " + message)
    end

  end

end
