require "fileutils"
require "pith/input/abstract"

module Pith
  module Input

    class Verbatim < Abstract

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
      
    end

  end
end
