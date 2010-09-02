require "set"
require "pathname"
require "ostruct"
require "tilt"

module Pith
  
  class RenderContext
    
    include Tilt::CompileSite
    
    def initialize(project)
      @project = project
      @input_stack = []
      @dependencies = project.config_files.dup
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
      with_input(input) do
        result = input.render(self, locals, &block)
        layout_ref = current_input.meta["layout"]
        result = render_ref(layout_ref) { result } if layout_ref
        result
      end
    end

    attr_reader :dependencies
    
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
    
    def page
      @page ||= OpenStruct.new(initial_input.meta)
    end
    
    def href(target_ref)
      relative_path_to(resolve_path(target_ref))
    end

    def link(target_ref, label = nil)
      target_path = resolve_path(target_ref)
      label ||= begin
        find_input(target_path).title
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
    
    def find_input(path)
      input = project.input(path)
      @dependencies << input.file if input
      input
    end
    
    def with_input(input)
      @dependencies << input.file
      @input_stack.push(input)
      begin
        yield
      ensure
        @input_stack.pop
      end
    end
    
    def render_ref(template_ref, locals = {}, &block)
      template_path = resolve_path(template_ref)
      template = find_input(template_path)
      render(template, locals, &block)
    end

  end
  
end
