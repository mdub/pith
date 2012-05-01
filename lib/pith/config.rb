module Pith

  class Config

    DEFAULT_IGNORE_PATTERNS = ["_*", ".git", ".gitignore", ".svn", ".sass-cache", "*~", "*.sw[op]"].to_set.freeze

    def initialize
      @ignore_patterns = DEFAULT_IGNORE_PATTERNS.dup
    end

    attr_reader :ignore_patterns
    attr_accessor :assume_content_negotiation
    attr_accessor :assume_directory_index

    def ignore(pattern)
      ignore_patterns << pattern
    end

    def helper_module
      @helper_module ||= Module.new
    end

    def helpers(&block)
      helper_module.module_eval(&block)
    end

  end

end
