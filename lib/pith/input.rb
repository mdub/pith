require "pith/input/template"
require "pith/input/resource"

module Pith
  module Input

    class << self

      def new(project, path)
        if Template.can_handle?(path)
          Template.new(project, path)
        else
          Resource.new(project, path)
        end
      end

    end

  end
end