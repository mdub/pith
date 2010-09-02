require "pathname"
require "logger"
require "pith/input"
require "tilt"

module Pith
  
  class Project
    
    def initialize(attributes = {})
      attributes.each do |k,v|
        send("#{k}=", v)
      end
    end
    
    attr_accessor :input_dir, :output_dir

    # Public: get inputs
    #
    # Returns Pith::Input objects representing the files in the input_dir.
    #
    # The list of inputs is cached after first load; 
    #   call #refresh to discard the cached data.
    #
    def inputs
      @inputs ||= Pathname.glob(input_dir + "**/*").map do |input_file|
        next if input_file.directory?
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
      raise ReferenceError, "Can't find #{path.inspect}"
    end

    # Public: build the project, generating output files.
    #
    def build
      refresh
      load_config
      inputs.each do |input| 
        input.build
      end
    end
    
    # Public: discard cached data that is out-of-sync with the file-system.
    #
    def refresh
      @inputs = nil
      @config_files = nil
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
        Pathname.glob("#{input_dir}/_pith/**")
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
    
  class ReferenceError < StandardError; end
  
end
