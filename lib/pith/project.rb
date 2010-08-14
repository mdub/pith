require "pathname"
require "logger"
require "pith/input"
require "tilt"

module Pith
  
  class Project
    
    def initialize(attributes = {})
      attributes.each do |k,v|
        send("#{k}=", v)
      end
    end
    
    attr_accessor :input_dir, :output_dir
    
    def inputs
      Pathname.glob(input_dir + "**/*").map do |input_file|
        unless input_file.directory?
          path = input_file.relative_path_from(input_dir)
          Input.new(self, path)
        end 
      end.compact
    end
    
    def input(name)
      input_dir + name
    end
    
    def build
      inputs.each do |input| 
        input.build
      end
    end

    def serve
      require "pith/server"
      Pith::Server.run(self)
    end
    
    def logger
      @logger ||= Logger.new(nil)
    end
    
    attr_writer :logger
    
  end
  
end
