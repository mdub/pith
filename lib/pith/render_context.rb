require "pathname"
require "tilt"

module Pith
  
  class RenderContext
    
    include Tilt::CompileSite
    
    def initialize(input)
      @input_stack = [input]
      self.extend(input.project.helper_module)
    end
    
    def initial_input
      @input_stack.first
    end

    def current_input
      @input_stack.last
    end
    
    def include(name, locals = {}, &block)
      including_input = current_input
      included_input = including_input.relative_input(name)
      with_input(included_input) do
        content_block = if block_given?
          content = with_input(including_input) do
            capture_haml(&block)
          end
          proc { content }
        end
        current_input.render(self, locals, &content_block)
      end
    end
    
    def content_for
      @content_for_hash ||= Hash.new { "" }
    end
    
    def meta
      initial_input.meta || {}
    end
    
    def href(name)
      target_path = current_input.relative_path(name)
      target_path.relative_path_from(initial_input.path.parent)
    end

    def link(target, label)
      %{<a href="#{href(target)}">#{label}</a>}
    end
    
    private
    
    def with_input(input)
      @input_stack.push(input)
      begin
        yield
      ensure
        @input_stack.pop
      end
    end

  end
  
end
