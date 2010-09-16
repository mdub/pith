require "pith/input"
require "time"

module Pith
  module Input

    class Abstract
      
      def published?
        false
      end
      
    end

    class Template

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

