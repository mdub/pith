require "pith/config"
require "pith/observable"

module Pith

  class ConfigProvider

    include Pith::Observable

    def initialize(project)
      @project = project
      @last_load_mtime = :never
      sync
    end

    attr_reader :config

    def sync
      config_mtime = config_file.mtime rescue nil
      unless config_mtime == @last_load_mtime
        @last_load_mtime = config_mtime
        @project.logger.debug "loading config"
        @config = Pith::Config.load(config_file)
        notify_observers
      end
    end

    private

    def config_file
      @project.input_dir + "_pith/config.rb"
    end

  end

end
