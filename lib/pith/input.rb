require "pith/render_context"
require "pith/metadata"

module Pith
  
  # Represents a file in the input directory.
  #
  class Input
    
    def initialize(project, path)
      @project = project
      @path = path
    end

    attr_reader :project, :path
    
    # Public: Get the file-system location of this input.
    #
    # Returns a fully-qualified Pathname.
    #
    def full_path
      project.input_dir + path
    end
    
    # Public: Get YAML metadata declared in the header of of a template.
    # 
    # The first line of the template must end with "---".  Any preceding characters
    # are considered to be a comment prefix, and are stripped from the following
    # lines.  The metadata block ends when the comment block ends, or a line ending
    # with "..." is encountered.
    #
    # Examples
    #
    #   Given input starting with:
    #
    #     -# ---
    #     -# published: 2008-09-15
    #     -# ...
    #
    #   input.meta
    #   #=> { "published" => "2008-09-15" }
    #  
    # Returns a Hash.
    #
    def meta
      if @metadata.nil?
        full_path.open do |io|
          @metadata = Pith::Metadata.extract_from(io).freeze
        end
      end
      @metadata
    end

    # Public: Generate a corresponding output file.
    #
    # Returns the output Pathname.
    # Returns nil if no output was generated.
    #
    def build
      ignore || evaluate_as_tilt_template || copy_verbatim
    end
    
    # Public: Resolve a reference relative to this input.
    #
    # href - a String referencing another asset
    #
    # An href starting with "/" is resolved relative to the project root;
    # anything else is resolved relative to this input.
    #
    # Returns a fully-qualified Pathname of the asset.
    #
    def relative_path(href)
      href = href.to_str
      if href[0,1] == "/"
        Pathname(href[1..-1])
      else
        path.parent + href
      end
    end

    # Resolve a reference relative to this input.
    #
    # href - a String referencing another asset
    #
    # Returns a fully-qualified Pathname of the asset.
    #
    def relative_input(href)
      resolved_path = relative_path(href)
      project.input(resolved_path)
    end
    
    private

    def logger
      project.logger
    end

    def trace(strategy, output_path = nil)
      output_path ||= "X"
      logger.info("%-36s%-14s%s" % [path, "--(#{strategy})-->", output_path])
    end
    
    # Consider whether this input can be ignored.
    #
    # Returns true if it can.
    #
    def ignore
      path.to_s.split("/").any? { |component| component.to_s[0,1] == "_" }
    end

    alias :ignorable? :ignore

    # Render this input using Tilt, if it looks like a template.
    #
    # Returns true if output was rendered.
    #
    def evaluate_as_tilt_template
      if path.to_s =~ /^(.*)\.(.*)$/ && RenderContext.can_render?($2)
        output_path = Pathname($1); ext = $2
        trace(ext, output_path)
        output_file = project.output_dir + output_path
        output_file.parent.mkpath
        output_file.open("w") do |out|
          output = RenderContext.new(project).render(self)
          out.puts(output)
        end
        output_file
      end
    end

    # Copy this input verbatim into the output directory
    #
    def copy_verbatim
      trace("copy", path)
      output_path = project.output_dir + path
      output_path.parent.mkpath
      FileUtils.copy(full_path, output_path)
      output_path
    end

  end
    
end
