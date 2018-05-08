require "listen"
require "logger"
require "pith/config_provider"
require "pith/input"
require "pith/pathname_ext"
require "pith/reference_error"
require "set"
require "tilt"
require "thread"

module Pith

  class Project

    def initialize(input_dir, output_dir = nil, attributes = {})
      @input_dir = Pathname(input_dir)
      @output_dir = output_dir ? Pathname(output_dir) : (@input_dir + "_out")
      @logger = Logger.new(nil)
      attributes.each do |k,v|
        send("#{k}=", v)
      end
      @input_map = {}
      @output_map = {}
      @mtimes ||= {}
      @config_provider ||= Pith::ConfigProvider.new(self)
      @mutex = Mutex.new
    end

    attr_reader :input_dir
    attr_reader :output_dir

    # Public: get inputs
    #
    # Returns Pith::Input objects representing the files in the input_dir.
    #
    def inputs
      @input_map.values
    end

    # Public: get outputs
    #
    # Returns Pith::Output objects representing the files in the output_dir.
    #
    def outputs
      inputs.map(&:output).compact
    end

    # Public: find an input.
    #
    # path - an path relative to input_dir
    #
    # Returns the first input whose path matches.
    # Returns nil if no match is found.
    #
    def input(path)
      @input_map[Pathname(path)]
    end

    # Public: find an output.
    #
    # path - an path relative to output_dir
    #
    # Returns the first output whose path matches.
    # Returns nil if no match is found.
    #
    def output(path)
      @output_map[Pathname(path)]
    end

    # Public: build the project, generating output files.
    #
    def build
      sync
      output_dir.mkpath
      outputs.each(&:build)
      output_dir.touch
    end

    # Public: re-sync with the file-system.
    #
    def sync
      @mutex.synchronize do
        config_provider.sync
        sync_input_files
        cleanup_output_files
      end
    end

    # Public: start a Thread to automatically sync when inputs change.
    #
    def listen_for_changes
      Listen.to(input_dir.to_s) do
        sync
      end.start
    end

    # Public: check for errors.
    #
    # Returns true if any errors were encountered during the last build.
    def has_errors?
      outputs.any?(&:error)
    end

    def last_built_at
      output_dir.mtime
    end

    attr_reader :logger
    attr_reader :config_provider

    def config
      config_provider.config
    end

    private

    attr_writer :logger

    def sync_input_files
      removed_paths = @mtimes.keys
      Pathname.glob(input_dir + "**/*", File::FNM_DOTMATCH) do |file|
        next unless file.file?
        next if file.in?(output_dir)
        mtime = file.mtime
        path = file.relative_path_from(input_dir)
        if @mtimes.has_key?(path)
          if @mtimes[path] < mtime
            file_modified(path)
          end
        else
          file_added(path)
        end
        @mtimes[path] = mtime
        removed_paths.delete(path)
      end
      removed_paths.each do |path|
        @mtimes.delete(path)
        file_removed(path)
      end
    end

    def cleanup_output_files
      Pathname.glob(output_dir + "**/*", File::FNM_DOTMATCH) do |file|
        next unless file.file?
        path = file.relative_path_from(output_dir)
        unless output(path)
          logger.info "XXX #{path}"
          FileUtils.rm_f(file)
        end
      end
    end

    def file_added(path)
      i = Input.new(self, path)
      i.when_added
      @input_map[path] = i
      if o = i.output
        @output_map[o.path] = o
      end
    end

    def file_modified(path)
      @input_map[path].when_modified
    end

    def file_removed(path)
      i = @input_map.delete(path)
      i.when_removed
      if o = i.output
        @output_map.delete(o.path)
      end
    end

  end

end
