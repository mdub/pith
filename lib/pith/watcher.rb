module Pith

  class Watcher

    DEFAULT_INTERVAL = 2

    def initialize(project, options = {})
      @project = project
      @interval = DEFAULT_INTERVAL
      options.each do |k,v|
        send("#{k}=", v)
      end
    end

    attr_accessor :project
    attr_accessor :interval

    def call
      loop do
        begin
          project.build
          sleep(interval)
        rescue Interrupt
          break
        end
      end
    end

  end

end
