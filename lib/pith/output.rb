require "fileutils"
require "pith/render_context"
require "set"

module Pith

  class Output

    def self.for(input, path)
      new(input, path)
    end

    def initialize(input, path)
      @input = input
      @path = path
      @dependencies = Set.new
    end

    attr_reader :input
    attr_reader :error
    attr_reader :path

    def project
      input.project
    end

    def file
      @file ||= project.output_dir + path
    end

    # Generate output for this template
    #
    def build
      return false if @generated
      logger.info("--> #{path}")
      file.parent.mkpath
      if input.template?
        evaluate_template
      else
        copy_resource
      end
      @generated = true
    end

    def observe_changes_to(*dependencies)
      dependencies.each do |d|
        @dependencies << d
        d.add_observer(self)
      end
    end

    def update # called by dependencies that change
      @dependencies.each do |d|
        d.delete_observer(self)
      end
      input.when_output_invalidated
    end

    private

    def copy_resource
      FileUtils.copy(input.file, file)
      observe_changes_to(input)
    end

    def evaluate_template
      render_context = RenderContext.new(self)
      file.open("w") do |out|
        begin
          @error = nil
          out.puts(render_context.render(input))
        rescue StandardError, SyntaxError => e
          @error = e
          logger.warn exception_summary(e, :max_backtrace => 5)
          out.puts "<pre>"
          out.puts exception_summary(e)
        end
      end
      observe_changes_to(*project.config_inputs)
    end

    def logger
      project.logger
    end

    def exception_summary(e, options = {})
      max_backtrace = options[:max_backtrace] || 999
      trimmed_backtrace = e.backtrace[0, max_backtrace]
      (["#{e.class}: #{e.message}"] + trimmed_backtrace).join("\n    ") + "\n"
    end

  end

end
