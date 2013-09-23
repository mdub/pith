require 'set'

module Pith

  class Config

    DEFAULT_IGNORE_PATTERNS = ["_*", ".git", ".gitignore", ".svn", ".sass-cache", "*~", "*.sw[op]"].to_set.freeze

    def initialize
      @ignore_patterns = DEFAULT_IGNORE_PATTERNS.dup
      @helper_module = Module.new
    end

    attr_accessor :assume_content_negotiation
    attr_accessor :assume_directory_index

    attr_reader :ignore_patterns

    def ignore(*pattern)
      pattern.flatten.each {|p| ignore_patterns << p }
    end

    attr_reader :helper_module

    def helpers(&block)
      helper_module.module_eval(&block)
    end

    class << self

      def load(config_file)
        config = self.new
        if config_file.exist?
          project = config # for backward compatibility
          eval(config_file.read, binding, config_file.to_s, 1)
        end
        config
      end

    end

  end

end
