module Pith

  module Observable

    def add_observer(observer, signal = :update)
      observer_map[observer] = signal
    end

    def remove_observer(observer)
      observer_map.delete(observer)
    end

    def notify_observers
      observer_map.each do |observer, signal|
        observer.send(signal)
      end
    end

    private

    def observer_map
      @observer_map ||= {}
    end

  end

end
