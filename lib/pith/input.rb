require "pith/input/template"
require "pith/input/verbatim"

module Pith
  module Input

    class << self

      def new(project, path)
        if path.to_s =~ /^(.*)\.(.*)$/ && RenderContext.can_render?($2)
          Template.new(project, path)
        else
          Verbatim.new(project, path)
        end
      end

    end

  end
end