require "pathname"
require "pith/metadata"

module Pith
  module Input

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
      def file
        project.input_dir + path
      end

      def output_file
        project.output_dir + output_path
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
          file.open do |io|
            @metadata = Pith::Metadata.extract_from(io).freeze
          end
        end
        @metadata
      end

      # Public: Get page title.
      #
      # The default title is based on the input file-name, sans-extension, capitalised,
      # but can be overridden by providing a "title" in the metadata block.
      #
      # Examples
      #
      #  input.path.to_s
      #  #=> "some_page.html.haml"
      #  input.title
      #  #=> "Some page"
      # 
      def title
        meta["title"] || default_title
      end
      
      # Public: Generate a corresponding output file.
      #
      def build
        return false if ignorable? || uptodate?
        logger.info("%-36s%-14s%s" % [path, "--(#{type})-->", output_path])
        generate_output 
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
      def resolve_path(href)
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
      def resolve_input(href)
        project.input(resolve_path(href))
      end

      # Consider whether this input can be ignored.
      #
      # Returns true if it can.
      #
      def ignorable?
        path.to_s.split("/").any? { |component| component.to_s[0,1] == "_" }
      end

      protected
        
      def default_title
        path.to_s.sub(/\..*/, '').tr('_-', ' ').capitalize
      end

      def logger
        project.logger
      end

    end

  end
end
