require "pith/render_context"
require "pith/metadata"
require "fileutils"

module Pith
  module Input

    class << self

      def new(project, path)
        if path.to_s =~ /^(.*)\.(.*)$/ && RenderContext.can_render?($2)
          Template.new(project, path)
        else
          Verbatim.new(project, path)
        end
      end

    end

    class Abstract

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
        generate_output unless ignorable? || uptodate?
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
      # Returns the referenced Input.
      #
      def relative_input(href)
        project.input(relative_path(href))
      end

      # Consider whether this input can be ignored.
      #
      # Returns true if it can.
      #
      def ignorable?
        path.to_s.split("/").any? { |component| component.to_s[0,1] == "_" }
      end

      protected

      def logger
        project.logger
      end

      def trace(strategy, output_path = nil)
        output_path ||= "X"
        logger.info("%-36s%-14s%s" % [path, "--(#{strategy})-->", output_path])
      end

    end

    class Template < Abstract
      
      def initialize(project, path)
        super(project, path)
        path.to_s =~ /^(.*)\.(.*)$/
        @output_path = $1
        @type = $2
      end

      attr_reader :output_path, :type
      
      def full_output_path
        project.output_dir + output_path
      end
      
      def uptodate?
        return false if all_input_paths.nil?
        FileUtils.uptodate?(full_output_path, all_input_paths)
      end
      
      # Render this input using Tilt
      #
      def generate_output
        trace(type, output_path)
        full_output_path.parent.mkpath
        render_context = RenderContext.new(project)
        full_output_path.open("w") do |out|
          out.puts(render_context.render(self))
        end
        remember_dependencies(render_context.rendered_inputs)
      end

      private

      def remember_dependencies(rendered_inputs)
        @all_input_paths = rendered_inputs.map { |input| input.full_path }
      end

      def all_input_paths
        @all_input_paths
      end
      
    end

    class Verbatim < Abstract

      def full_output_path
        project.output_dir + path
      end
      
      def uptodate?
        FileUtils.uptodate?(full_output_path, [full_path])
      end
      
      # Copy this input verbatim into the output directory
      #
      def generate_output
        trace("copy", path)
        full_output_path.parent.mkpath
        FileUtils.copy(full_path, full_output_path)
      end
      
    end
    
  end
end