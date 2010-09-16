require "time"

module Pith
  module Plugins

    module Publication

      module Template

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

      module Project

        def published_inputs
          inputs.select do |input|
            input.respond_to?(:published_at) && !input.published_at.nil?
          end.sort_by do |input|
            input.published_at
          end
        end

      end

    end

  end
end

require "pith/input/template"
Pith::Input::Template.send(:include, Pith::Plugins::Publication::Template)

require "pith/project"
Pith::Project.send(:include, Pith::Plugins::Publication::Project)
