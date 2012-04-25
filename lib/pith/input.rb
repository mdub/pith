require "fileutils"
require "pathname"
require "pith/output"
require "tilt"
require "yaml"

module Pith
  class Input

    def initialize(project, path)
      @project = project
      @path = path
      determine_pipeline
    end

    attr_reader :project, :path

    attr_reader :output_path
    attr_reader :pipeline
    attr_reader :load_time

    # Public: Get the file-system location of this input.
    #
    # Returns a fully-qualified Pathname.
    #
    def file
      @file ||= project.input_dir + path
    end

    # Public: Get the file-system location of the corresponding output file.
    #
    # Returns a fully-qualified Pathname.
    #
    def output_file
      @output_file ||= project.output_dir + output_path
    end

    def output
      unless ignorable?
        @output ||= Output.for(self)
      end
    end

    # Consider whether this input can be ignored.
    #
    # Returns true if it can.
    #
    def ignorable?
      @ignorable ||= path.each_filename do |path_component|
        project.ignore_patterns.each do |pattern|
          return true if File.fnmatch(pattern, path_component)
        end
      end
    end

    # Determine whether this input is a template, requiring evaluation.
    #
    # Returns true if it is.
    #
    def template?
      !pipeline.empty?
    end

    def refresh
      unload if file.mtime.to_i >= load_time.to_i
    end

    # Render this input using Tilt
    #
    def render(context, locals = {}, &block)
      return file.read if !template?
      ensure_loaded
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
      ensure_loaded
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

    # Make sure we've loaded the input file.
    #
    def ensure_loaded
      load unless @load_time
    end

    # Read input file, extracting YAML meta-data header, and template content.
    #
    def load
      @load_time = Time.now
      @meta = {}
      if template?
       file.open do |io|
          read_meta(io)
          @template_start_line = io.lineno + 1
          @template_text = io.read
        end
      end
    end

    def read_meta(io)
      header = io.gets
      if header =~ /^---/
        while line = io.gets
          break if line =~ /^(---|\.\.\.)/
          header << line
        end
        begin
          @meta = YAML.load(header)
        rescue ArgumentError, SyntaxError
          logger.warn "#{file}:1: badly-formed YAML header"
        end
      else
        io.rewind
      end
    end

    # Note that the input file has changed, so we'll need to re-load it.
    #
    def unload
      @load_time = nil
    end

    def logger
      project.logger
    end

  end

end
