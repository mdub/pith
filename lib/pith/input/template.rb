require "fileutils"
require "pathname"
require "pith/input/abstract"
require "pith/render_context"
require "tilt"
require "yaml"

module Pith
  module Input

    # Represents an input that should be evaluated as a template.
    #
    class Template < Abstract

      def self.can_handle?(path)
        !!Tilt[path.to_s]
      end

      def initialize(project, path)
        raise(ArgumentError, "#{path} is not a template") unless Template.can_handle?(path)
        super(project, path)
        determine_pipeline
        load
      end

      attr_reader :output_path

      # Check whether output is up-to-date.
      #
      # Return true unless output needs to be re-generated.
      #
      def uptodate?
        dependencies && FileUtils.uptodate?(output_file, dependencies)
      end

      # Generate output for this template
      #
      def generate_output
        output_file.parent.mkpath
        render_context = RenderContext.new(project)
        output_file.open("w") do |out|
          begin
            out.puts(render_context.render(self))
          rescue StandardError, SyntaxError => e
            logger.warn exception_summary(e, :max_backtrace => 5)
            out.puts "<pre>"
            out.puts exception_summary(e)
          end
        end
        @dependencies = render_context.dependencies
      end

      # Render this input using Tilt
      #
      def render(context, locals = {}, &block)
        @pipeline.inject(@template_text) do |text, processor|
          template = processor.new(file.to_s, @template_start_line) { text }
          template.render(context, locals, &block)
        end
      end

      # Public: Get YAML metadata declared in the header of of a template.
      #
      # If the first line of the template starts with "---" it is considered to be
      # the start of a YAML 'document', which is loaded and returned.
      #
      # Examples
      #
      #   Given input starting with:
      #
      #     ---
      #     published: 2008-09-15
      #     ...
      #     OTHER STUFF
      #
      #   input.meta
      #   #=> { "published" => "2008-09-15" }
      #
      # Returns a Hash.
      #
      def meta
        @meta
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

      private

      def default_title
        path.basename.to_s.sub(/\..*/, '').tr('_-', ' ').capitalize
      end

      def determine_pipeline
        @pipeline = []
        remaining_path = path.to_s
        while remaining_path =~ /^(.+)\.(.+)$/
          if Tilt[$2]
            remaining_path = $1
            @pipeline << Tilt[$2]
          else
            break
          end
        end
        @output_path = Pathname(remaining_path)
      end

      # Read input file, extracting YAML meta-data header, and template content.
      #
      def load
        file.open do |input|
          load_meta(input)
          load_template(input)
        end
      end

      def load_meta(input)
        @meta = {}
        header = input.gets
        if header =~ /^---/
          while line = input.gets
            break if line =~ /^(---|\.\.\.)/
            header << line
          end
          begin
            @meta = YAML.load(header)
          rescue ArgumentError, SyntaxError
            logger.warn "#{file}:1: badly-formed YAML header"
          end
        else
          input.rewind
        end
      end

      def load_template(input)
        @template_start_line = input.lineno + 1
        @template_text = input.read
      end

      attr_accessor :dependencies

      def exception_summary(e, options = {})
        max_backtrace = options[:max_backtrace] || 999
        trimmed_backtrace = e.backtrace[0, max_backtrace]
        (["#{e.class}: #{e.message}"] + trimmed_backtrace).join("\n    ") + "\n"
      end

    end

  end
end
