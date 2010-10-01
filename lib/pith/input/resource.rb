require "fileutils"
require "pith/input/abstract"

module Pith
  module Input

    # Represents a non-template input.
    #
    class Resource < Abstract

      def output_path
        path
      end
      
      def type
        "copy"
      end
      
      def uptodate?
        FileUtils.uptodate?(output_file, [file])
      end
      
      # Copy this input verbatim into the output directory
      #
      def generate_output
        output_file.parent.mkpath
        FileUtils.copy(file, output_file)
      end

      # Render this input, for inclusion within templates
      #
      def render(context, locals = {})
        file.read
      end

      def meta
        {}
      end
      
    end

  end
end
