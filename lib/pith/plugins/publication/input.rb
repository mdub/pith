require "pith/input"
require "time"

module Pith
  module Plugins
    module Publication

      module TemplateMethods

        def published?
          !published_at.nil?
        end

        def published_at
          parse_timestamp(meta["published"])
        end

        def updated_at
          parse_timestamp(meta["updated"]) || published_at
        end

        private

        def parse_timestamp(arg)
          return unless arg
          return arg.to_time if arg.respond_to?(:to_time)
          Time.parse(arg.to_s)
        end

      end

    end
  end
end

module Pith
  class Input
    include Pith::Plugins::Publication::TemplateMethods
  end
end
