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
      included_input = @input.relative_input(name)
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
    
    def content_for
      @content_for_hash ||= Hash.new { "" }
    end
    
    def meta
      input.meta || {}
    end
    
    def href(target)
      if target.to_s =~ %r{^/(.*)}
        current_page = input.path
        Pathname($1).relative_path_from(current_page.parent)
      else
        target
      end
    end

    def link(target, label)
      %{<a href="#{href(target)}">#{label}</a>}
    end
        
  end
  
end
