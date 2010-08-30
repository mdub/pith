require "set"
require "pathname"
require "tilt"

module Pith
  
  class RenderContext
    
    include Tilt::CompileSite
    
    def initialize(project)
      @project = project
      @input_stack = []
      @rendered_inputs = Set.new
      self.extend(project.helper_module)
    end

    attr_reader :project
    
    def initial_input
      @input_stack.first
    end

    def current_input
      @input_stack.last
    end
    
    def render(input, locals = {}, &block)
      @rendered_inputs << input
      with_input(input) do
        result = input.render(self, locals, &block)
        layout_ref = current_input.meta["layout"]
        result = render_ref(layout_ref) { result } if layout_ref
        result
      end
    end

    attr_reader :rendered_inputs
    
    def include(template_ref, locals = {}, &block)
      content_block = if block_given?
        content = capture_haml(&block)
        proc { content }
      end
      render_ref(template_ref, locals, &content_block)
    end
    
    alias :inside :include
    
    def content_for
      @content_for_hash ||= Hash.new { "" }
    end
    
    def meta
      initial_input.meta || {}
    end
    
    def href(target_ref)
      relative_path_to(resolve_path(target_ref))
    end

    def link(target_ref, label = nil)
      target_path = resolve_path(target_ref)
      label ||= begin
        project.input(target_path).title
      rescue Pith::ReferenceError
        "???"
      end
      %{<a href="#{relative_path_to(target_path)}">#{label}</a>}
    end
    
    private

    def relative_path_to(target_path)
      target_path.relative_path_from(initial_input.path.parent)
    end
    
    def resolve_path(ref)
      current_input.resolve_path(ref)
    end
    
    def with_input(input)
      @input_stack.push(input)
      begin
        yield
      ensure
        @input_stack.pop
      end
    end
    
    def render_ref(template_ref, locals = {}, &block)
      template = project.input(resolve_path(template_ref))
      render(template, locals, &block)
    end

  end
  
end
