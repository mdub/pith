require "pathname"
require "tilt"

module Pith
  
  class OutputContext
    
    include Tilt::CompileSite
    
    def initialize(input)
      @input = input
    end
    
    attr_reader :input

    def include(name, locals = {}, &block)
      original_input = @input
      included_input = @input.resolve(name)
      begin
        content_block = if block_given?
          content = capture_haml(&block)
          proc { content }
        end
        @input = included_input
        @input.render(self, locals, &content_block)
      ensure
        @input = original_input
      end
    end
    
    def link(href, label)
      if href.to_s =~ %r{^/(.*)}
        current_page = input.path
        target_page = Pathname($1)
        href = target_page.relative_path_from(current_page.parent)
      end
      %{<a href="#{href}">#{label}</a>}
    end
        
  end
  
end
