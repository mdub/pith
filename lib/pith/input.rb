require "pith/input/template"
require "pith/input/verbatim"

module Pith
  module Input

    class << self

      def new(project, path)
        Template.new(project, path)
      rescue Template::UnrecognisedType
        Verbatim.new(project, path)
      end

    end

  end
end