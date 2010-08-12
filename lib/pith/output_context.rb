require "pathname"
require "tilt"

module Pith
  
  class OutputContext
    
    include Tilt::CompileSite
    
    def initialize(input)
      @input = input
      @input_stack = [input]
    end
    
    attr_reader :input

    def initial_input
      @input_stack.first
    end

    def current_input
      @input_stack.last
    end
    
    def include(name, locals = {}, &block)
      @input_stack.push(current_input.relative_input(name))
      begin
        content_block = if block_given?
          content = capture_haml(&block)
          proc { content }
        end
        current_input.render(self, locals, &content_block)
      ensure
        @input_stack.pop
      end
    end
    
    def content_for
      @content_for_hash ||= Hash.new { "" }
    end
    
    def meta
      input.meta || {}
    end
    
    def href(name)
      target_path = current_input.relative_path(name)
      target_path.relative_path_from(input.path.parent)
    end

    def link(target, label)
      %{<a href="#{href(target)}">#{label}</a>}
    end
        
  end
  
end
