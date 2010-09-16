require "pith/project"
require "pith/plugins/publication/input"

module Pith

  class Project

    def published_inputs
      inputs.select { |i| i.published? }.sort_by { |i| i.published_at }
    end

  end

end
