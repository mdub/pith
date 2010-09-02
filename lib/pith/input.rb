require "pith/input/template"
require "pith/input/resource"

module Pith
  module Input

    class << self

      def new(project, path)
        Template.new(project, path)
      rescue Template::UnrecognisedType
        Resource.new(project, path)
      end

    end

  end
end