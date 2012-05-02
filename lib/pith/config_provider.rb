require "pith/config"
require "pith/observable"

module Pith

  class ConfigProvider

    include Pith::Observable

    def initialize(project)
      @project = project
    end

    def config
      @config ||= load_config
    end

    def sync
      config_mtime = config_file.mtime rescue nil
      unless config_mtime == @last_mtime
        @config = nil
        @last_mtime = config_mtime
        notify_observers
      end
    end

    private

    def config_file
      @project.input_dir + "_pith/config.rb"
    end

    def load_config
      @project.logger.debug "loading config"
      Pith::Config.load(config_file)
    end

  end

end
