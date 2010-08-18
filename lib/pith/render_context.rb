require "set"
require "pathname"
require "tilt"

module Pith
  
  class RenderContext
    
    include Tilt::CompileSite
    
    def self.can_render?(extension)
      Tilt.registered?(extension)
    end
    
    def initialize(project)
      @input_stack = []
      @rendered_inputs = Set.new
      self.extend(project.helper_module)
    end
    
    def initial_input
      @input_stack.first
    end

    def current_input
      @input_stack.last
    end
    
    def render(input, locals = {}, &block)
      @rendered_inputs << input
      with_input(input) do
        Tilt.new(input.full_path).render(self, locals, &block)
      end
    end

    attr_reader :rendered_inputs
    
    def include(name, locals = {}, &block)
      included_input = current_input.relative_input(name)
      content_block = if block_given?
        content = capture_haml(&block)
        proc { content }
      end
      render(included_input, locals, &content_block)
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
