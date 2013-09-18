require "ostruct"
require "pathname"
require "pith/reference_error"
require "set"
require "tilt"

module Pith

  class RenderContext

    include Tilt::CompileSite

    def initialize(output)
      @output = output
      @page = @output.input
      @project = @page.project
      @input_stack = []
      self.extend(project.config.helper_module)
    end

    attr_reader :output
    attr_reader :page
    attr_reader :project

    def page
      @input_stack.first
    end

    def current_input
      @input_stack.last
    end

    def render(input, locals = {}, &block)
      with_input(input) do
        result     = input.render(self, locals, &block)
        layout_ref = input.meta["layout"]
        result     = render_ref(layout_ref) { result } if layout_ref
        result
      end
    end

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

    def relative_url_to(target_path)
      url = target_path.relative_path_from(page.path.parent).to_s
      url = url.sub(/index\.html$/, "") if project.config.assume_directory_index
      url = url.sub(/\.html$/, "") if project.config.assume_content_negotiation
      url = "./" if url.empty?
      Pathname(url)
    end

    def href(target_ref)
      relative_url_to(resolve_reference(target_ref))
    end

    def link(target_ref, label = nil, attrs={})

      if absolute_url? target_ref
        attrs['href'] = target_ref
      else
        target_path = resolve_reference(target_ref)
        attrs['href'] = relative_url_to(target_path)
      end

      label ||= begin
        target_input = input(target_path)
        output.record_dependency_on(target_input)
        target_input.title
      rescue ReferenceError
        "???"
      end
      
      # Loop through attrs hash, flatten the key, value
      # pairs for appending to the dom element/link
      attrs_flatten = attrs.each_pair.collect do |key, value|
                        %Q{#{key}="#{value}"}
                      end.join(' ')
      
      "<a #{attrs_flatten}>#{label}</a>"
    end

    private
    
    def absolute_url?(ref)
      
      # Need host and absolute as the ruby URI library will say that 
      # http:/example.com is absolute, but don't have a domain
      
      begin
        url = URI.parse(ref.to_s)
        url.absolute? and !url.host.nil?
      rescue URI::InvalidURIError
        false
      end
    end

    def resolve_reference(ref)
      if ref.kind_of?(Pith::Input)
        raise(ReferenceError, %{No output for "#{ref.path}"}) if ref.output.nil?
        ref.output.path
      else
        current_input.resolve_path(ref)
      end
    end

    def input(path)
      project.input(path) ||
      input_with_output_path(path) ||
      raise(ReferenceError, %{Can't find "#{path}"})
    end

    def input_with_output_path(path)
      o = project.output(path)
      o ? o.input : nil
    end

    def with_input(input)
      output.record_dependency_on(input)
      @input_stack.push(input)
      begin
        yield
      ensure
        @input_stack.pop
      end
    end

    def render_ref(template_ref, locals = {}, &block)
      template_input = input(resolve_reference(template_ref))
      render(template_input, locals, &block)
    end

  end

end
