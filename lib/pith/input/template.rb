require "fileutils"
require "pathname"
require "pith/input/abstract"
require "pith/render_context"
require "tilt"

module Pith
  module Input

    class Template < Abstract

      class UnrecognisedType < StandardError; end
      
      def initialize(project, path)
        super(project, path)
        path.to_s =~ /^(.*)\.(.*)$/
        @output_path = Pathname($1)
        @type = $2
        raise(UnrecognisedType, @type) unless Tilt.registered?(@type)
      end

      attr_reader :output_path, :type

      def uptodate?
        all_input_files && FileUtils.uptodate?(output_file, all_input_files)
      end

      # Generate output for this template
      #
      def generate_output
        output_file.parent.mkpath
        render_context = RenderContext.new(project)
        output_file.open("w") do |out|
          out.puts(render_context.render(self))
        end
        remember_dependencies(render_context.rendered_inputs)
      end

      # Render this input using Tilt
      #
      def render(context, locals = {}, &block)
        Tilt.new(file).render(context, locals, &block)
      end

      private

      def remember_dependencies(rendered_inputs)
        @all_input_files = rendered_inputs.map { |input| input.file }
      end

      attr_accessor :all_input_files

    end

  end
end
