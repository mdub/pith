require "pathname"
require "tilt"

module Pith
  
  class Page
    
    include Tilt::CompileSite
    
    def initialize(input)
      @input = input
    end
    
    attr_reader :input

    def resolve_template(template_name)
      input.relative_path.parent + template_name
    end
    
    def include(name, locals = {}, &block)
      content_block = if block_given?
        content = capture_haml(&block)
        proc { content }
      end
      input.project.render(resolve_template(name), self, locals, &content_block)
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
