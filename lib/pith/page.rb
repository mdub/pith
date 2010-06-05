require "pathname"
require "tilt"

module Pith
  
  class Page
    
    include Tilt::CompileSite
    
    def initialize(input)
      @input = input
      @current_template = input.relative_path
    end
    
    attr_reader :input

    def resolve_template(name)
      @current_template.parent + name
    end
    
    def include(name, locals = {}, &block)
      original_template = @current_template
      included_template = resolve_template(name)
      begin
        content_block = if block_given?
          content = capture_haml(&block)
          proc { content }
        end
        @current_template = included_template
        input.project.render(included_template, self, locals, &content_block)
      ensure
        @current_template = original_template
      end
    end
    
    def link(href, label)
      if href.to_s =~ %r{^/(.*)}
        current_page = input.relative_path
        target_page = Pathname($1)
        href = target_page.relative_path_from(current_page.parent)
      end
      %{<a href="#{href}">#{label}</a>}
    end
        
  end
  
end
