require "logger"
require "pith/input"
require "pith/pathname_ext"
require "pith/reference_error"
require "tilt"

module Pith

  class Project

    DEFAULT_IGNORE_PATTERNS = ["_*", ".git", ".svn", "*~"].freeze

    def initialize(attributes = {})
      @ignore_patterns = DEFAULT_IGNORE_PATTERNS.dup
      attributes.each do |k,v|
        send("#{k}=", v)
      end
    end

    attr_reader :input_dir
    attr_reader :ignore_patterns

    def input_dir=(dir)
      @input_dir = Pathname(dir)
    end

    attr_reader :output_dir

    def output_dir=(dir)
      @output_dir = Pathname(dir)
    end

    attr_accessor :assume_content_negotiation
    attr_accessor :assume_directory_index

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
    # path - an path relative to either input_dir or output_dir
    #
    # Returns the first input whose input_path or output_path matches.
    # Returns nil if no match is found.
    #
    def input(path)
      path = Pathname(path)
      inputs.find do |input|
        input.matches_path(path)
      end
    end

    # Public: build the project, generating output files.
    #
    def build
      refresh
      load_config
      output_dir.mkpath
      remove_invalid_outputs
      outputs.each(&:build)
      output_dir.touch
    end

    # Public: discard cached data that is out-of-sync with the file-system.
    #
    def refresh
      @config_files = nil
      @input_map ||= {}
      validate_known_inputs
      find_new_inputs
    end

    # Public: check for errors.
    #
    # Returns true if any errors were encountered during the last build.
    def has_errors?
      inputs.map(&:output).compact.any?(&:error)
    end

    def last_built_at
      output_dir.mtime
    end

    def logger
      @logger ||= Logger.new(nil)
    end

    attr_writer :logger

    def helpers(&block)
      helper_module.module_eval(&block)
    end

    def helper_module
      @helper_module ||= Module.new
    end

    def config_files
      @config_files ||= begin
        input_dir.all_files("_pith/**")
      end.to_set
    end

    private

    def load_config
      config_file = input_dir + "_pith/config.rb"
      project = self
      if config_file.exist?
        eval(config_file.read, binding, config_file.to_s, 1)
      end
    end

    def validate_known_inputs
      @input_map.reject! { |_, input| !input.file.exist? }
      @input_map.each do |_, input|
        input.refresh
      end
    end

    def find_new_inputs
      input_dir.all_files.map do |input_file|
        path = input_file.relative_path_from(input_dir)
        unless @input_map.has_key?(path)
          @input_map[path] = Input.new(self, path)
        end
      end
    end

    def remove_invalid_outputs
      valid_output_files = outputs.map(&:file)
      invalid_output_files = output_dir.all_files - valid_output_files
      invalid_output_files.each do |file|
        path = file.relative_path_from(output_dir)
        logger.info("--X #{path}")
        FileUtils.rm(file)
      end
    end

  end

end
