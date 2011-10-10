require "pith/input/template"

module Pith
  module Input

    class << self

      # Construct an object representing a project input file.
      #
      def new(project, path)
        Template.new(project, path)
      end

    end

  end
end