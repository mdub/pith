require "pathname"

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

      # Public: Get the file-system location of the corresponding output file.
      #
      # Returns a fully-qualified Pathname.
      #
      def output_file
        project.output_dir + output_path
      end

      # Public: Generate an output file.
      #
      def build
        return false if ignorable? || uptodate?
        logger.info("%-16s%s" % ["--(#{type})-->", output_path])
        generate_output 
      end

      # Public: Resolve a reference relative to this input.
      #
      # ref - a String referencing another asset
      #
      # A ref starting with "/" is resolved relative to the project root;
      # anything else is resolved relative to this input.
      #
      # Returns a fully-qualified Pathname of the asset.
      #
      def resolve_path(ref)
        ref = ref.to_s
        if ref[0,1] == "/"
          Pathname(ref[1..-1])
        else
          path.parent + ref
        end
      end

      # Consider whether this input can be ignored.
      #
      # Returns true if it can.
      #
      def ignorable?
        path.each_filename do |path_component|
          project.ignore_patterns.each do |pattern|
            return true if File.fnmatch(pattern, path_component)
          end
        end
      end

      protected

      def logger
        project.logger
      end

    end

  end
end
