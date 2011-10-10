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
          parse_date(meta["published"])
        end

        def updated_at
          parse_date(meta["updated"]) || published_at
        end

        private

        def parse_date(date_string)
          Time.parse(date_string) if date_string
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
