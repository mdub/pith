require "pathname"
require "logger"
require "pith/item"
require "tilt"

module Pith
  
  class Project
    
    def initialize(attributes = {})
      attributes.each do |k,v|
        send("#{k}=", v)
      end
    end
    
    attr_accessor :input_dir, :output_dir
    
    def items
      @items ||= Pathname.glob(input_dir + "**/*").map do |input_file|
        Item.new(self, input_file) unless input_file.directory?
      end.compact
    end
    
    def build
      items.each { |item| item.build }
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
