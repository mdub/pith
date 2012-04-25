require 'ref'

module Pith

  module Observable

    def add_observer(observer, method = :update)
      observer_map[observer] = method
    end

    def notify_observers
      observer_map.each do |observer, method|
        observer.send(method)
      end
    end

    protected

    def observer_map
      @observer_map ||= Ref::WeakKeyMap.new
    end

  end

end
