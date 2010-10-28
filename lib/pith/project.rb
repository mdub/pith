require "logger"
require "pith/input"
require "pith/pathname_ext"
require "pith/reference_error"
require "tilt"

module Pith
  
  class Project
    
    DEFAULT_IGNORE_PATTERNS = ["_*", ".git", ".svn"].freeze
    
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
    # The list of inputs is cached after first load; 
    #   call #refresh to discard the cached data.
    #
    def inputs
      @inputs ||= input_dir.all_files.map do |input_file|
        path = input_file.relative_path_from(input_dir)
        find_or_create_input(path)
      end.compact
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
      inputs.each do |input|
        return input if input.path == path || input.output_path == path
      end
      nil
    end

    # Public: build the project, generating output files.
    #
    def build
      refresh
      load_config
      remove_old_outputs
      generate_outputs
      output_dir.touch
    end
    
    # Public: discard cached data that is out-of-sync with the file-system.
    #
    def refresh
      @inputs = nil
      @config_files = nil
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
        eval(config_file.read, binding, config_file)
      end
    end
    
    def remove_old_outputs
      valid_output_paths = inputs.map { |i| i.output_path }
      output_dir.all_files.each do |output_file|
        output_path = output_file.relative_path_from(output_dir)
        unless valid_output_paths.member?(output_path)
          logger.info("removing        #{output_path}")
          FileUtils.rm(output_file)
        end
      end
    end
    
    def generate_outputs
      inputs.each do |input| 
        input.build
      end
    end

    def input_cache
      @input_cache ||= Hash.new do |h, cache_key|
        h[cache_key] = Input.new(self, cache_key.first)
      end
    end

    def find_or_create_input(path)
      file = input_dir + path
      cache_key = [path, file.mtime]
      input_cache[cache_key]
    end
    
  end
  
end
