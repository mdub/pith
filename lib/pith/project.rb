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
      @inputs ||= Pathname.glob(input_dir + "**/*").map do |input_file|
        Input.new(self, input_file) unless input_file.directory?
      end.compact
    end
    
    def build
      inputs.each { |input| input.build }
    end

    def logger
      @logger ||= Logger.new(nil)
    end
    
    def render(template_path, context, locals = {}, &block)
      template = Tilt.new(input_dir + template_path)
      template.render(context, locals, &block)
    end
    
  end
  
end
