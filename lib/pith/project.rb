require "logger"
require "pith/config_provider"
require "pith/input"
require "pith/pathname_ext"
require "pith/reference_error"
require "set"
require "tilt"

module Pith

  class Project

    def initialize(input_dir, output_dir = nil, attributes = {})
      @input_dir = Pathname(input_dir)
      @output_dir = output_dir ? Pathname(output_dir) : (@input_dir + "_out")
      @input_map = {}
      @output_map = {}
      attributes.each do |k,v|
        send("#{k}=", v)
      end
      FileUtils.rm_rf(output_dir.to_s)
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
      config_provider.sync
      sync_input_files
    end

    def sync_every(period)
      @next_sync ||= 0
      now = Time.now.to_i
      if now >= @next_sync
        sync
        @next_sync = now + period
      end
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

    def logger
      @logger ||= Logger.new(nil)
    end

    def config_provider
      @config_provider ||= Pith::ConfigProvider.new(self)
    end

    def config
      config_provider.config
    end

    private

    attr_writer :logger

    def sync_input_files
      @mtimes ||= {}
      removed_paths = @mtimes.keys
      Pathname.glob(input_dir + "**/*", File::FNM_DOTMATCH) do |file|
        next unless file.file?
        next if file.in?(output_dir)
        mtime = file.mtime
        path = file.relative_path_from(input_dir)
        if @mtimes.has_key?(path)
          if @mtimes[path] < mtime
            when_file_modified(path)
          end
        else
          when_file_added(path)
        end
        @mtimes[path] = mtime
        removed_paths.delete(path)
      end
      removed_paths.each do |path|
        @mtimes.delete(path)
        when_file_removed(path)
      end
    end

    def when_file_added(path)
      i = Input.new(self, path)
      i.when_added
      @input_map[path] = i
      if o = i.output
        @output_map[o.path] = o
      end
    end

    def when_file_modified(path)
      @input_map[path].when_modified
    end

    def when_file_removed(path)
      i = @input_map.delete(path)
      i.when_removed
      if o = i.output
        @output_map.delete(o.path)
      end
    end

  end

end
